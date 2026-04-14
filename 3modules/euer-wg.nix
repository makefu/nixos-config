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
      ipv4 = mkOption {
        type = types.str;
        description = "IPv4 address of the peer in 172.27.70.0/24";
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

      keepalive = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Persistent keepalive (defaults to no keepalive)";
      };

      endpoint = mkOption {
        type = types.str;
        default = "";
        description = "Server endpoint IP or hostname (port is derived from euer-wg.port)";
      };

      ipv4DefaultRoute = mkEnableOption "route all IPv4 traffic through the tunnel (NAT via server)";

      ipv6DefaultRoute = mkOption {
        type = types.bool;
        default = true;
        description = "Route all IPv6 traffic through the tunnel via server";
      };
    };
  };

  config = mkIf active (mkMerge [
    # --- shared config (both server and client) ---
    {
      networking.hosts = mapAttrs'
        (name: peer: nameValuePair peer.ula [ "${name}.${cfg.tld}" ])
        cfg.peers
      // mapAttrs'
        (name: peer: nameValuePair peer.ipv4 [ "${name}.${cfg.tld}" ])
        cfg.peers;

      networking.firewall.allowedUDPPorts = [ cfg.port ];

      networking.wireguard.interfaces.euer = {
        ips =
          [ "${self.ula}/64" "${self.ipv4}/24" ]
          ++ optional (self.publicV6 != null) "${self.publicV6}/128";
        listenPort = cfg.port;
        privateKeyFile = config.sops.secrets."${machineName}-euer-wg.key".path;
      };
    }

    # --- server mode ---
    (mkIf isServer (let
      ext-if = cfg.server.external-interface;

      # all peer IPv6 addresses that may be forwarded through the tunnel
      peerForwardIPs = concatLists (mapAttrsToList (_: p:
        [ "${p.ula}/128" ]
        ++ optional (p.publicV6 != null) "${p.publicV6}/128"
      ) otherPeers);
    in {
      boot.kernel.sysctl = {
        "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
        "net.ipv4.ip_forward" = lib.mkDefault 1;
        # scope proxy_ndp to only the relevant interfaces
        "net.ipv6.conf.all.proxy_ndp" = lib.mkDefault 0;
        "net.ipv6.conf.euer.proxy_ndp" = lib.mkDefault 1;
        "net.ipv6.conf.${ext-if}.proxy_ndp" = lib.mkDefault 1;
      };

      # NAT masquerade for IPv4 tunnel traffic (clients have no routed IPv4)
      networking.nat = {
        enable = true;
        internalInterfaces = [ "euer" ];
        externalInterface = ext-if;
      };

      networking.wireguard.interfaces.euer = {
        peers = mapAttrsToList (_: p: {
          publicKey = p.publicKey;
          allowedIPs =
            [ "${p.ula}/128" "${p.ipv4}/32" ]
            ++ optional (p.publicV6 != null) "${p.publicV6}/128";
        }) otherPeers;
      };

      # restrict IPv6 FORWARD chain: only allow traffic to/from known peer IPs
      # via the euer tunnel interface; drop everything else being forwarded
      networking.firewall.extraCommands = let
        ip6 = "${pkgs.iptables}/bin/ip6tables";
      in ''
        # flush old euer rules to make this idempotent on rebuild
        ${ip6} -D FORWARD -i euer -j euer-fwd 2>/dev/null || true
        ${ip6} -D FORWARD -o euer -j euer-fwd 2>/dev/null || true
        ${ip6} -F euer-fwd 2>/dev/null || true
        ${ip6} -X euer-fwd 2>/dev/null || true

        ${ip6} -N euer-fwd
        # allow established/related (return traffic)
        ${ip6} -A euer-fwd -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        # allow forwarding only for known peer addresses
        ${concatStringsSep "\n" (map (addr:
          "${ip6} -A euer-fwd -s ${addr} -j ACCEPT\n${ip6} -A euer-fwd -d ${addr} -j ACCEPT"
        ) peerForwardIPs)}
        # drop anything else transiting the tunnel
        ${ip6} -A euer-fwd -j DROP

        ${ip6} -A FORWARD -i euer -j euer-fwd
        ${ip6} -A FORWARD -o euer -j euer-fwd
      '';

      networking.firewall.extraStopCommands = let
        ip6 = "${pkgs.iptables}/bin/ip6tables";
      in ''
        ${ip6} -D FORWARD -i euer -j euer-fwd 2>/dev/null || true
        ${ip6} -D FORWARD -o euer -j euer-fwd 2>/dev/null || true
        ${ip6} -F euer-fwd 2>/dev/null || true
        ${ip6} -X euer-fwd 2>/dev/null || true
      '';

      # NDP proxy setup as a separate service (postSetup/postShutdown
      # are not supported with networkd)
      systemd.services.euer-ndp-proxy = let
        setupScript = pkgs.writeShellScript "euer-ndp-proxy-setup" (
          concatStringsSep "\n" (map (addr:
            "${pkgs.iproute2}/bin/ip -6 neigh add proxy ${addr} dev ${ext-if}"
          ) ndpProxyAddrs)
        );
        teardownScript = pkgs.writeShellScript "euer-ndp-proxy-teardown" (
          concatStringsSep "\n" (map (addr:
            "${pkgs.iproute2}/bin/ip -6 neigh del proxy ${addr} dev ${ext-if}"
          ) ndpProxyAddrs)
        );
      in mkIf (ndpProxyAddrs != []) {
        description = "NDP Proxy for euer WireGuard peers";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = setupScript;
          ExecStop = teardownScript;
        };
      };
    }))

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
            "172.27.70.0/24"  # IPv4 internal range (NATed via server)
          ] ++ optional cfg.client.ipv6DefaultRoute
            "::/0"            # default route for IPv6 internet via server
          ++ optional cfg.client.ipv4DefaultRoute
            "0.0.0.0/0";      # default route for IPv4 internet via server
          persistentKeepalive = cfg.client.keepalive;
        }
      ];
    }))
  ]);
}
