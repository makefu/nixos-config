{ config, pkgs, lib, ... }:

# Declarative Radicle seed node on omo, running inside a NixOS systemd-nspawn
# container that joins the same wireguard-isolated `ipfs` netns used by the
# kubo container (see 2configs/ipfs/omo-container.nix). Sharing the netns
# means we re-use the `omo-ipfs` wireguard peer — radicle-node listens on
# the same publicV6, just on a different TCP port (8776).
#
# Identity
# --------
# Public key is committed below; matching private key is stored as the
# clan-managed sops secret `omo-radicle.key` (unencrypted OpenSSH ed25519,
# `cipher=none`, generated via `rad auth --alias omo` with an empty
# RAD_PASSPHRASE). Regenerating the keypair means re-running `rad auth`,
# replacing `publicKeyLiteral` here and `clan secrets set omo-radicle.key`.

let
  # Same netns + wg interface as ipfs — radicle re-uses the omo-ipfs peer.
  netns = "ipfs";
  domain = "rad.syntax-fehler.de";
  ifname = "ipfs-wg";
  dataDir = "/media/silent/db/radicle";

  port = 8081;
  # Pinned seed repositories. Add more RIDs as needed.
  #
  # NOTE: `web.pinned.repositories` (below) only controls what the explorer UI
  # lists; it does NOT make the node seed/fetch them. Actual seeding is a node
  # policy stored in the node database (`rad seed <rid>`), which the nixpkgs
  # module has no declarative option for — so the `radicle-seed` oneshot below
  # applies these as seeding policies after the node starts.
  pinnedRepos = [
    "rad:zaCSBVa8UbKNEWBcmRTW1m9fZXhu"
  ];

  # Upstream seed the node connects to on startup (and maintains), used as the
  # fetch source for our seeded repos. This must go in `node.connect`: the node
  # config schema has no `preferredSeeds` field (that is a rad-CLI concept) —
  # unknown keys land in the ignored `extra` map, so the daemon would never act
  # on them.
  #
  # The official iris/rosa seeds RST omo's handshake (its Hetzner IPv6 range
  # appears blocked) — only seed.radicle.dev accepts us, and it is reachable
  # over IPv6 (2a01:4f9:c011:b666::1). Port 58776 is the canonical p2p port
  # these seeds announce (8776 is stale/unreachable).
  connectSeeds = [
    "z6MksmpU5b1dS7oaqF2bHXhQi1DWy2hB7Mh9CuN7y1DN6QSz@seed.radicle.dev:58776"
  ];

  # Public ed25519 from `rad auth`. The nixpkgs radicle module rejects keys
  # with a trailing comment, so keep the line as just `ssh-ed25519 <b64>`.
  publicKeyLiteral = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF39eDCYctHnyEbNexSGCSCb27+tK8ZvhCKrMN0zRTu5";

  # Reachable address announced to peers. Matches omo-ipfs.publicV6.
  externalV6 = config.makefu.euer-wg.peers."omo-ipfs".publicV6;

  # Stable uid/gid so the bind-mounted dataDir is owned by the same id
  # on host and inside the container. radicle has no nixpkgs-reserved id;
  # 391 is unused on omo.
  radicleUid = 391;
  radicleGid = 391;

  # Host-side wrapper: `rad` on the host shells into the container's
  # rad-system (which enters radicle-node's mount/user namespace).
  radHost = pkgs.writeShellScriptBin "rad" ''
    exec ${pkgs.nixos-container}/bin/nixos-container run radicle -- rad-system "$@"
  '';
in {
  imports = [
    ../wireguard/euer/omo-ipfs-netns.nix
  ];

  sops.secrets."omo-radicle.key" = {};

  users.users.root.packages = [ radHost ];

  users.users.radicle = {
    isSystemUser = true;
    group = "radicle";
    uid = radicleUid;
    description = "radicle seed-node data owner (host side)";
  };
  users.groups.radicle.gid = radicleGid;

  systemd.tmpfiles.settings."10-radicle-data" = {
    "${dataDir}".d = {
      user = "radicle";
      group = "radicle";
      mode = "0750";
    };
  };

  containers.radicle = {
    autoStart = true;
    privateNetwork = false;
    extraFlags = [
      "--network-namespace-path=/run/netns/${netns}"
      "--resolv-conf=off"
    ];
    bindMounts = {
      "/var/lib/radicle" = {
        hostPath = dataDir;
        isReadOnly = false;
      };
      "/etc/resolv.conf" = {
        hostPath = "/etc/netns/${netns}/resolv.conf";
        isReadOnly = true;
      };
      "/run/radicle.key" = {
        hostPath = config.sops.secrets."omo-radicle.key".path;
        isReadOnly = true;
      };
    };
    config = { config, pkgs, lib, ... }: let
      # radicle-explorer web UI, built with our seed baked in as the
      # preferred seed. http-only for now; once omo gets a public hostname
      # this becomes scheme=https on port 443 (see services.radicle.httpd.nginx
      # in nixpkgs / Mic92's eve config for the SSL variant).
      radicleExplorer = pkgs.radicle-explorer.withConfig {
        preferredSeeds = [{
          hostname = domain;
          port = 443;
          scheme = "https";
        }];
      };
    in {
      system.stateVersion = "26.05";

      networking.useDHCP = false;
      networking.useHostResolvConf = false;
      networking.firewall.enable = false;
      systemd.network.enable = false;

      # Pin uid/gid to match the host bind-mount owner.
      users.users.radicle.uid = lib.mkForce radicleUid;
      users.groups.radicle.gid = lib.mkForce radicleGid;

      services.radicle = {
        enable = true;
        privateKey = "/run/radicle.key";
        publicKey = publicKeyLiteral;
        node = {
          listenAddress = "[::]";
          listenPort = 8776;
        };
        # Web API backing radicle-explorer and `rad` HTTP clients. Kept on
        # loopback (8081) — nginx below fronts it on :80 and proxies /api/
        # to it same-origin (avoids CORS). 8080 is the kubo IPFS gateway
        # sharing this netns, so httpd uses 8081.
        httpd = {
          enable = true;
          listenAddress = "127.0.0.1";
          listenPort = port;
        };
        settings = {
          node.alias = "omo";
          node.externalAddresses = [
            "[${externalV6}]:8776"
          ];
          node.connect = connectSeeds;
          web.pinned.repositories = pinnedRepos;
        };
      };

      # Apply seeding policies for the pinned repos. The radicle module only
      # writes config.json (default policy = block); per-repo seeding lives in
      # the node's policy database and must be set via `rad seed` — the node
      # config schema has no per-repo seed list, so this cannot be expressed in
      # services.radicle.settings. Without it the node never fetches the repos.
      #
      # `rad` needs the node's keys/config, which only exist inside the
      # radicle-node service's confinement namespace; a standalone `rad` fails
      # with "Could not load Radicle profile". Use the module's `rad-system`
      # wrapper, which nsenters into that namespace. It needs root for nsenter,
      # so this runs as root. `rad seed` is idempotent, so re-runs are cheap.
      systemd.services.radicle-seed = {
        description = "Apply radicle seeding policies for pinned repos";
        after = [ "radicle-node.service" ];
        bindsTo = [ "radicle-node.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          set -eu
          rad="/run/current-system/sw/bin/rad-system"
          sock="/var/lib/radicle/node/control.sock"
          for _ in $(seq 1 60); do
            [ -S "$sock" ] && break
            sleep 1
          done
          ${lib.concatMapStringsSep "\n"
            (rid: ''"$rad" seed ${lib.escapeShellArg rid} --scope all'')
            pinnedRepos}
        '';
      };

      security.acme.acceptTerms = true;

      # Front radicle-explorer + httpd on :80. Listens on the container's
      # routed publicV6 (and loopback); gum forwards :80 via
      # omo-ipfs.openTCPPorts. http-only until omo has a public hostname for
      # ACME — then add forceSSL + a 443 listener here.
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedGzipSettings = true;
        virtualHosts."${domain}" = {
          default = true;
          enableACME = true;
          forceSSL = true;
          quic = true;
          root = "${radicleExplorer}";
          # SPA: serve static assets, fall back to index.html for routes.
          locations."/" = {
            tryFiles = "$uri $uri/ /index.html =404";
            extraConfig = ''
              expires 1h;
              add_header Cache-Control "public";
            '';
          };
          # Seed HTTP API — same-origin proxy to radicle-httpd on loopback.
          locations."/api/" = {
            proxyPass = "http://127.0.0.1:${toString port}";
          };
        };
      };
    };
  };

  # Wait for /media/silent (xfs on nvme, no mergerfs) + netns + wg.
  systemd.services."container@radicle" = {
    after = [
      "media-silent.mount"
      "netns-${netns}.service"
      "wireguard-${ifname}.service"
    ];
    requires = [
      "media-silent.mount"
      "netns-${netns}.service"
      "wireguard-${ifname}.service"
    ];
    unitConfig.RequiresMountsFor = [ dataDir ];
  };
}
