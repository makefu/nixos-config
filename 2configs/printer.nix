{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [
      pkgs.samsungUnifiedLinuxDriver
    ];
  };
}
