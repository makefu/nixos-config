# Reverse-proxy jack.r:8000 (vLLM on jack) for retiolum clients.
# Bound to gum's tinc addresses only, so the port is unreachable from the
# public interfaces; the firewall additionally allows 8000 on tinc.retiolum.
{ config, lib, ... }:
let
  jack = config.krebs.hosts.jack.nets.retiolum;
  self = config.krebs.self.nets.retiolum;
in
lib.mkIf (jack.ip6 != null) {
  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."jack.r" = {
      serverName = "jack.r";
      # explicit listen lines so the vhost does not inherit the global
      # 0.0.0.0/[::0] defaults and leak onto the public interfaces
      listen = [
        { addr = self.ip4.addr; port = 8000; }
        { addr = "[${self.ip6.addr}]"; port = 8000; }
      ];
      # jack has no retiolum ip4; bracket the ipv6 or nginx parses the
      # last hextet as the port
      locations."/" = {
        proxyPass = "http://[${jack.ip6.addr}]:8000";
        proxyWebsockets = true;
      };
    };
  };

  # bind only after the tinc interface exists, else nginx fails to assign
  # the retiolum address at boot
  systemd.services.nginx = {
    after = [ "sys-subsystem-net-devices-tinc.retiolum.device" ];
    requires = [ "sys-subsystem-net-devices-tinc.retiolum.device" ];
  };

  networking.firewall.interfaces."tinc.retiolum".allowedTCPPorts =
    lib.mkDefault [ 8000 ];
}
