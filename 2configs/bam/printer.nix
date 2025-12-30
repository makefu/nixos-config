{ pkgs, config, ... }:
let
  mainUser = config.krebs.build.user.name;
in {
  imports = [
    # ./brother-ql-web.nix
  ];
  services.printing = {
    enable = true;
    drivers = with pkgs;[
      brlaser
      cups-ptouch
    ];
  };
  users.users.${mainUser} = {
      extraGroups = [ "scanner" "lp" ];
      packages = with pkgs;[
        python312Packages.brother-ql
        libreoffice
        qrencode
        imagemagick
    ];
  };
  state = [ "/var/lib/cups"];

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="04f9", ATTRS{idProduct}=="209b", ATTRS{serial}=="000F1Z401759", MODE="0664", GROUP="lp", SYMLINK+="usb/lp0"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="04f9", ATTRS{idProduct}=="209d", ATTRS{serial}=="000F1Z401759", MODE="0664", GROUP="lp", SYMLINK+="usb/lp0"
  '';

}
