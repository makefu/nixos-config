{config, lib, pkgs, ... }:

{
  options.state = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "state which is currently scattered on the machine";
    default = [];
  };
}
