{ config, lib, pkgs, modulesPath, ... }:
let
  external-mac = "96:00:01:24:33:f4";
  external-gw = "172.31.1.1";
  external-ip = "142.132.189.140";
  external-ip6 = "2a01:4f8:1c17:5cdf::2/64";
  external-gw6 = "fe80::1";
  external-netmask = 32;
  external-netmask6 = 64;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
  ext-if = "et0"; # gets renamed on the fly
in
{
  makefu.server.primary-itf = ext-if;
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="${external-mac}", NAME="${ext-if}"
  '';
  networking = {
    interfaces."${ext-if}" = {
      useDHCP = true;
    };
    #ipv4.addresses = [{
    #  address = external-ip;
    #  prefixLength = external-netmask;
    #}];
    #ipv6.addresses = [{
    #    address = external-ip6;
    #    prefixLength = external-netmask6;
    #  }];
    #};
    #defaultGateway6 = { address = external-gw6; interface = ext-if; };
    #defaultGateway = external-gw;
    nameservers = [ "1.1.1.1" ];
  };
}
