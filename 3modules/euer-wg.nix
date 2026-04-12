{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.makefu.euer-wg;
  machineName = cfg.hostname;
  self = cfg.peers.${machineName};
  otherPeers = removeAttrs cfg.peers [ machineName ];

  isServer = cfg.server.enable;
  isClient = cfg.client.enable;
  active = isServer || isClient;

  peerSubmodule = types.submodule {
    options = {
      ula = mkOption {
        type = types.str;
        description = "ULA address of the peer";
      };
      publicKey = mkOption {
        type = types.str;
        description = "WireGuard public key of the peer";
      };
      publicV6 = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Public IPv6 from gum's /64 assigned to this peer on the tunnel";
      };
    };
  };

  # server: collect public IPv6 addresses of other peers for NDP proxying
  ndpProxyAddrs = filter (a: a != null)
    (mapAttrsToList (_: p: p.publicV6) otherPeers);

in {
  options.makefu.euer-wg = {
    hostname = mkOption {
      type = types.str;
      default = config.clan.core.settings.machine.name;
      description = "This machine's name in the peers attrset";
    };

    tld = mkOption {
      type = types.str;
      default = "euer";
      description = "TLD used for internal hostnames (e.g. gum.euer)";
    };

    port = mkOption {
      type = types.port;
      default = 51826;
      description = "WireGuard listen port";
    };

    peers = mkOption {
      type = types.attrsOf peerSubmodule;
      default = {};
      description = "All peers in the euer network";
    };

    server = {
      enable = mkEnableOption "euer WireGuard server mode (NDP proxy, IPv6 forwarding)";

      external-interface = mkOption {
        type = types.str;
        default = config.makefu.server.primary-itf;
        description = "External interface for NDP proxying";
      };
    };

    client = {
      enable = mkEnableOption "euer WireGuard client mode";

      serverPeer = mkOption {
        type = types.str;
        default = "gum";
        description = "Name of the server peer to connect to";
      };

      endpoint = mkOption {
        type = types.str;
        default = "";
        description = "Server endpoint IP or hostname (port is derived from euer-wg.port)";
      };
    };
  };

  config = mkIf active (mkMerge [
    # --- shared config (both server and client) ---
    {
      networking.hosts = mapAttrs'
        (name: peer: nameValuePair peer.ula [ "${name}.${cfg.tld}" ])
        cfg.peers;

      networking.firewall.allowedUDPPorts = [ cfg.port ];

      networking.wireguard.interfaces.euer = {
        ips =
          [ "${self.ula}/64" ]
          ++ optional (self.publicV6 != null) "${self.publicV6}/128";
        listenPort = cfg.port;
        privateKeyFile = config.sops.secrets."${machineName}-euer-wg.key".path;
      };
    }

    # --- server mode ---
    (mkIf isServer {
      boot.kernel.sysctl = {
        "net.ipv6.conf.all.forwarding" = 1;
        "net.ipv6.conf.all.proxy_ndp" = 1;
      };

      networking.wireguard.interfaces.euer = let
        ext-if = cfg.server.external-interface;
      in {
        postSetup = concatStringsSep "\n" (map (addr:
          "${pkgs.iproute2}/bin/ip -6 neigh add proxy ${addr} dev ${ext-if}"
        ) ndpProxyAddrs);

        postShutdown = concatStringsSep "\n" (map (addr:
          "${pkgs.iproute2}/bin/ip -6 neigh del proxy ${addr} dev ${ext-if}"
        ) ndpProxyAddrs);

        peers = mapAttrsToList (_: p: {
          publicKey = p.publicKey;
          allowedIPs =
            [ "${p.ula}/128" ]
            ++ optional (p.publicV6 != null) "${p.publicV6}/128";
        }) otherPeers;
      };
    })

    # --- client mode ---
    (mkIf isClient (let
      server = cfg.peers.${cfg.client.serverPeer};
    in {
      networking.wireguard.interfaces.euer.peers = [
        {
          publicKey = server.publicKey;
          endpoint = "${cfg.client.endpoint}:${toString cfg.port}";
          allowedIPs = [
            "fd42:euer::/64"  # ULA range for internal traffic
            "::/0"            # default route for IPv6 internet via server
          ];
          persistentKeepalive = 25;
        }
      ];
    }))
  ]);
}
