{ pkgs, config, ... }:
let
  mainUser = config.krebs.build.user.name;
in {
  imports = [
    ./brother-ql-web.nix
  ];
  services.printing = {
    enable = true;
    drivers = with pkgs;[
      brlaser
      cups-ptouch
    ];
  };
  users.users.kiosk.extraGroups = [ "scanner" "lp" ];
  state = [ "/var/lib/cups"];
  users.users.kiosk.packages = with pkgs;[
    python3Packages.brother-ql
    libreoffice
    qrencode
    imagemagick
  ];

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="04f9", ATTRS{idProduct}=="209b", ATTRS{serial}=="000F1Z401759", MODE="0664", GROUP="lp", SYMLINK+="usb/lp0"
  '';

}
