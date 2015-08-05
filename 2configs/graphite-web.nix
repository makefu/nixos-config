{ config, lib, pkgs, ... }:

with lib;
{
  imports = [ ];
  services.graphite = {
    web = {
      enable = true;
      host = "0.0.0.0";
    };
    carbon = {
      enableCache = true;
      storageSchemas = ''
        [carbon]
        pattern = ^carbon\.
        retentions = 60:90d

        [default]
        pattern = .*
        retentions = 60s:30d,300s:1y
        '';
    };
  };
}
