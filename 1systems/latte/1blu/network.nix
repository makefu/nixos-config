{ config, lib, pkgs, modulesPath, ... }:
let
  external-mac = "c4:37:72:55:4e:1c";
  external-gw = "178.254.28.1";
  external-ip = "178.254.30.202";
  external-ip6 = "2a00:6800:3:18c::2";
  external-gw6 = "2a00:6800:3::1";
  external-netmask = 22;
  external-netmask6 = 64;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
  ext-if = "et0"; # gets renamed on the fly
in
{
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="${external-mac}", NAME="${ext-if}"
  '';
  networking = {
    interfaces."${ext-if}" = {
    ipv4.addresses = [{
      address = external-ip;
      prefixLength = external-netmask;
    }];
    ipv6.addresses = [{
        address = external-ip6;
        prefixLength = external-netmask6;
      }];
    };
    defaultGateway6 = { address = external-gw6; interface = ext-if; };
    defaultGateway = external-gw;
  };
}
