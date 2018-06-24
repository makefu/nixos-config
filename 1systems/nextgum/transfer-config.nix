{ config, lib, ... }:
# configuration which is only required for the time of the transfer
{
  krebs.tinc.retiolum.connectTo = [ "gum" ];
  krebs.build.host = lib.mkForce config.krebs.hosts.nextgum;
}

