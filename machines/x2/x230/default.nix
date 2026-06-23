{lib, ... }:
{
    imports = [
        ../../../2configs/hw/tp-x230.nix
        ./encrypted-zfs.nix
        ./tang.nix
        ./wifi.nix
        ./secureboot.nix

  ];
  boot.tmp.useTmpfs = true;
  services.fwupd.enable = true;
  hardware.acpilight.enable = true;
}
