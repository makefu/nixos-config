{config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  options.makefu.stats-server = lib.mkOption {
    type = types.str;
    default = "omo.retiolum";
    description = "Central stats server (collectd)";
  };
}

