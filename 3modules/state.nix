{config, lib, pkgs, ... }:

{
  options.state = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "state which is currently scattered on the machine";
    default = [];
  };

  config.system.activationScripts.state =  lib.optionalString (config.state != []) ''
    cat << EOF
    This machine is burdened with state:
    ${lib.concatMapStringsSep "\n" (d: "* ${d}") config.state}
    EOF
  '';
}
