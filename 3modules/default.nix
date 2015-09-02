{ config, lib, ... }:

with lib;
let
  cfg = config.krebs;

  out = {
    imports = [
    ];
    options.krebs = api;
    config = mkIf cfg.enable imp;
  };

  api = { };

  imp = { };

in
out
