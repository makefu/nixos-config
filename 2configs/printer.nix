{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [
      pkgs.samsungUnifiedLinuxDriver
    ];
  };

  # scanners are printers just in reverse anyway
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.samsungUnifiedLinuxDriver ];
}
