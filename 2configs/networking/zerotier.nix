{ lib, config, ... }:
{
  # lassulus network
  clan.core.networking.zerotier = {
    networkId = "ccc5da5295c853d4";
    name = "nether";
  };
  services.zerotierone.localConf.settings.interfacePrefixBlacklist = [ "ygg" "mesh" "retiolum" "wiregrill" ];
}
