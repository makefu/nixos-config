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
  #networking.nat =  mkIf isRouter {
  #  enable = true;
  #  enableIPv6 = true;
  #  externalInterface = ext-if;
  #  internalInterfaces = [ "wiregrill" ];
  #};

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

  networking.wireguard.interfaces.wiregrill = let 
    ipt = "${pkgs.iptables}/bin/iptables";
    ip6 = "${pkgs.iptables}/bin/ip6tables";
  in {
    postSetup = ''
        ${ipt} -A FORWARD -i wiregrill -o retiolum -j ACCEPT
        ${ipt} -A FORWARD -i wiregrill -o wiregrill -j ACCEPT
        ${ipt} -A FORWARD -o wiregrill -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        ${ip6} -A FORWARD -i wiregrill -o retiolum -j ACCEPT
        ${ip6} -A FORWARD -i retiolum -o wiregrill -j ACCEPT
        ${ip6} -A FORWARD -i wiregrill -o wiregrill -j ACCEPT
        ${ip6} -A FORWARD -o wiregrill -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    '' + (optionalString isRouter ''
        #${ipt} -t nat -A PREROUTING -s 10.244.245.0/24 -j ACCEPT
        #${ipt} -t nat -A POSTROUTING -s 10.244.245.0/24 ! -d 10.244.245.0/24 -j MASQUERADE

        #${ip6} -t nat -A PREROUTING -s 42:1::/32 -j ACCEPT
        #${ip6} -t nat -A POSTROUTING -s 42:1::/32 ! -d 42:1::/48 -j MASQUERADE
    '');

      # This undoes the above command
      postShutdown = ''
        ${ipt} -D FORWARD -i wiregrill -o retiolum -j ACCEPT
        ${ipt} -D FORWARD -i retiolum -o wiregrill -j ACCEPT
        ${ipt} -D FORWARD -i wiregrill -o wiregrill -j ACCEPT
        ${ipt} -D FORWARD -i wiregrill -o wiregrill -j ACCEPT
        ${ipt} -D FORWARD -o wiregrill -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        ${ip6} -D FORWARD -i wiregrill -o retiolum -j ACCEPT
        ${ip6} -D FORWARD -i retiolum -o wiregrill -j ACCEPT
        ${ip6} -D FORWARD -i wiregrill -o wiregrill -j ACCEPT
        ${ip6} -D FORWARD -o wiregrill -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

      '' + (optionalString isRouter ''

        ${ipt} -t nat -D PREROUTING -s 10.244.245.0/24 -j ACCEPT
        ${ipt} -t nat -D POSTROUTING -s 10.244.245.0/24 -j MASQUERADE

        #${ip6} -t nat -D PREROUTING -s 42:1::/32 -j ACCEPT
        #${ip6} -t nat -D POSTROUTING -s 42:1::/32 ! -d 42:1::/48 -j MASQUERADE
    '' );
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
