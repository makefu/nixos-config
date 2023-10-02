
{ config, pkgs, lib, ... }: with lib; 
let

  self = config.krebs.build.host.nets.wiregrill;
  ext-if = config.makefu.server.primary-itf;

in mkIf (hasAttr "wiregrill" config.krebs.build.host.nets) {
  #hack for modprobe inside containers
  systemd.services."wireguard-wiregrill".path = mkIf config.boot.isContainer (mkBefore [
    (pkgs.writeDashBin "modprobe" ":")
  ]);


  networking.firewall = {
    allowedUDPPorts = [ self.wireguard.port ];
  };


  networking.wireguard.interfaces.wiregrill = let 
    ipt = "${pkgs.iptables}/bin/iptables";
    ip6 = "${pkgs.iptables}/bin/ip6tables";
  in {
    ips =
      (optional (!isNull self.ip4) self.ip4.addr) ++
      (optional (!isNull self.ip6) self.ip6.addr);
    listenPort = self.wireguard.port;
    privateKeyFile = config.sops.secrets."${config.clanCore.machineName}-wiregrill.key".path;
    allowedIPsAsRoutes = true;
    peers = let
      host = config.krebs.hosts.gum;
    in [
      {
        allowedIPs = host.nets.wiregrill.wireguard.subnets ;
        endpoint = mkIf (!isNull host.nets.wiregrill.via) (host.nets.wiregrill.via.ip4.addr + ":${toString host.nets.wiregrill.wireguard.port}");
        persistentKeepalive = mkIf (!isNull host.nets.wiregrill.via) 61;
        publicKey = (replaceStrings ["\n"] [""] host.nets.wiregrill.wireguard.pubkey);
      }
    ];
  };
}
