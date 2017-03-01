{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [
      pkgs.samsungUnifiedLinuxDriver
      pkgs.dymo-cups-drivers
    ];
  };

  # scanners are printers just in reverse anyway
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.samsungUnifiedLinuxDriver ];
}
