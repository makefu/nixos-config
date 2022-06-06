{ config, pkgs, ... }:

let
  mainUser = config.krebs.build.user.name;
in {
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      # samsungUnifiedLinuxDriver
      splix # scx 3200
      cups-dymo # dymo labelwriter
      foo2zjs # magicolor 1690mf
      cups-zj-58
      cups-ptouch
    ];
  };

  users.users."${mainUser}".extraGroups = [ "scanner" "lp" ];

  # scanners are printers just in reverse anyway
  services.saned.enable = true;
  hardware.sane = {
    enable = true;
    extraBackends = [ ];
    extraConfig.xerox_mfp = ''
      usb 0x04e8 0x3441
    '';
    #netConf =
    #  # drucker.lan SCX-3205W
    #  ''
    #    192.168.111.16''
    #  # uhrenkind.shack magicolor 1690mf
    #+ ''
    #    10.42.20.30'';

    ## $ scanimage -p --format=jpg --mode=Gray --source="Automatic Document Feeder" -v --batch="lol%d.jpg" --resolution=150

    ## requires 'sane-extra', scan via:
    #extraConfig."magicolor" = ''
    #  net 10.42.20.30 0x2098
    #''; # 10.42.20.30: uhrenkind.shack magicolor 1690mf
  };
  state = [ "/var/lib/cups" ];
  services.udev.extraRules = ''
    ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="3441", ENV{libsane_matched}="yes"
  '';
}
