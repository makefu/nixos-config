{ lib, config, ... }:
{
  # lassulus network
  clan.networking.zerotier.networkId = "7c31a21e86f9a75c";
  services.zerotierone.localConf.settings.interfacePrefixBlacklist = [ "ygg" "mesh" "retiolum" "wiregrill" ];
}
