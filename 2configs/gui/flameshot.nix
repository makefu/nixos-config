{ pkgs, config, ... }: 
let
  mainUser = config.krebs.build.user.name;
in {
  # Terminal
  home-manager.users.${mainUser} = {
    services.flameshot = {
      enable = true;
    };
  };
}
