{ config, lib, pkgs, ... }:

# graphite-web on port 8080
# carbon cache on port 2003 (tcp/udp)
with import <stockholm/lib>;
{
  imports = [ ];

  services.graphite = {
    web = {
      enable = true;
      host = "0.0.0.0";
    };
    carbon = {
      enableCache = true;
      # save disk usage by restricting to 1 bulk update per second
      config = ''
        [cache]
        MAX_CACHE_SIZE = inf
        MAX_UPDATES_PER_SECOND = 1
        MAX_CREATES_PER_MINUTE = 50
        '';
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
