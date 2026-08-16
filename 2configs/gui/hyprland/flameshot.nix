{ pkgs, config, ... }: 
let
  mainUser = "makefu";
in {
  # Terminal
  home-manager.users.${mainUser} = {
    services.flameshot = {
      enable = true;
    };
  };
}
