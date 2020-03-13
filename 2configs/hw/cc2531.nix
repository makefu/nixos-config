{ config, lib, pkgs, ... }:

{

  users.users.${config.krebs.build.user.name}.extraGroups = [ "dialout" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a8", SYMLINK+="cc2531", MODE="0660", GROUP="dailout"
  '';
}
