{config, lib, pkgs, ... }:

with lib;{
  options.makefu.server.primary-itf = lib.mkOption {
    type = types.str;
    description = "Primary interface of the server";
  };
  options.makefu.gui.user = lib.mkOption {
    type = types.str;
    description = "GUI user";
    default = config.krebs.build.user.name;
  };
}

