{config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  options.makefu.stats-server = lib.mkOption {
    type = types.str;
    default = "stats.makefu.r";
    description = "Central stats server (collectd)";
  };
  options.makefu.log-server = lib.mkOption {
    type = types.str;
    default = "logs.makefu.r";
    description = "Central logging server (logstash,elasticsearch)";
  };
}

