{ config, ... }:
let
  mainUser = "makefu";
in {
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  #services.displayManager.autoLogin = {
  #  enable = true;
  #  user = mainUser;
  #};
}
