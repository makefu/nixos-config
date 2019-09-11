with import <stockholm/lib>;
{ config, pkgs, ... }: let

  self = config.krebs.build.host.nets.wiregrill;
  isRouter = !isNull self.via; # via "internet" is not set
  ext-if = config.makefu.server.primary-itf;

in mkIf (hasAttr "wiregrill" config.krebs.build.host.nets) {
  #hack for modprobe inside containers
  systemd.services."wireguard-wiregrill".path = mkIf config.boot.isContainer (mkBefore [
    (pkgs.writeDashBin "modprobe" ":")
  ]);

  boot.kernel.sysctl = mkIf isRouter {
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    allowedUDPPorts = [ self.wireguard.port ];
    extraCommands = ''
      iptables -A FORWARD -i wiregrill -o wiregrill -j ACCEPT
    '';
  };

  networking.wireguard.interfaces.wiregrill = {
    ips =
      (optional (!isNull self.ip4) self.ip4.addr) ++
      (optional (!isNull self.ip6) self.ip6.addr);
    listenPort = self.wireguard.port;
    privateKeyFile = (toString <secrets>) + "/wiregrill.key";
    allowedIPsAsRoutes = true;
    peers = mapAttrsToList
      (_: host: {
        allowedIPs = if isRouter then
          (optional (!isNull host.nets.wiregrill.ip4) host.nets.wiregrill.ip4.addr) ++
          (optional (!isNull host.nets.wiregrill.ip6) host.nets.wiregrill.ip6.addr)
        else
          host.nets.wiregrill.wireguard.subnets
        ;
        endpoint = mkIf (!isNull host.nets.wiregrill.via) (host.nets.wiregrill.via.ip4.addr + ":${toString host.nets.wiregrill.wireguard.port}");
        persistentKeepalive = mkIf (!isNull host.nets.wiregrill.via) 61;
        publicKey = (replaceStrings ["\n"] [""] host.nets.wiregrill.wireguard.pubkey);
      })
      (filterAttrs (_: h: hasAttr "wiregrill" h.nets) config.krebs.hosts);
  };
}
