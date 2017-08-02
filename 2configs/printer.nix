{ config, pkgs, ... }:

let
  mainUser = config.krebs.build.user.name;
in {
  services.printing = {
    enable = true;
    drivers = [
      pkgs.samsungUnifiedLinuxDriver
      pkgs.cups-dymo # dymo labelwriter
      pkgs.foo2zjs # magicolor 1690mf
    ];
  };

  # scanners are printers just in reverse anyway
  services.saned.enable = true;
  users.users."${mainUser}".extraGroups = [ "scanner" ];

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.samsungUnifiedLinuxDriver ];

    # $ scanimage -p --format=jpg --mode=Gray --source="Automatic Document Feeder" -v --batch="lol%d.jpg" --resolution=150

    # requires 'sane-extra', scan via:
    extraConfig."magicolor" = ''
      net 10.42.20.30 0x2098
    ''; # 10.42.20.30: uhrenkind.shack magicolor 1690mf
  };
}
