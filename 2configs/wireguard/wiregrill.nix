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
    "net.ipv4.conf.all.forwarding" = 1;
  };
  networking.nat =  mkIf isRouter {
    enable = true;
    enableIPv6 = true;
    externalInterface = ext-if;
    internalInterfaces = [ "wiregrill" ];
  };

  networking.firewall = {
    allowedUDPPorts = [ self.wireguard.port ];
    interfaces.wiregrill = mkIf isRouter {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };

  services.dnsmasq = mkIf isRouter {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = /* dnsmasq */ ''
      bind-interfaces
      interface=retiolum,wiregrill
    '';
    servers = [ "1.1.1.1" ];
  };

  networking.wireguard.interfaces.wiregrill = {
    postSetup = optionalString isRouter ''
        ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -s 10.244.245.0/24 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.244.245.0/24 ! -d 10.244.245.0/24 -j MASQUERADE
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wiregrill -o retiolum -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i retiolum -o wiregrill -j ACCEPT

        ${pkgs.iptables}/bin/ip6tables -t nat -A PREROUTING -s 42:1::/32 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s 42:1::/32 ! -d 42:1::/48 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wiregrill -o retiolum -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i retiolum -o wiregrill -j ACCEPT
    '';

      # This undoes the above command
    postShutdown = optionalString isRouter ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.244.245.0/24 -o ${ext-if} -j MASQUERADE
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wiregrill -o retiolum -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D FORWARD -i retiolum -o wiregrill -j ACCEPT

        ${pkgs.iptables}/bin/ip6tables -t nat -D PREROUTING -s 42:1::/32 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s 42:1::/32 ! -d 42:1::/48 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wiregrill -o retiolum -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i retiolum -o wiregrill -j ACCEPT
    '' ;
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
