{lib, ... }:
{
    imports = [
        ../../../2configs/hw/tp-x230.nix
    ../../../2configs/fs/disko/single-disk-encrypted-btrfs.nix

    # ../x13/secureboot.nix

     { makefu.server.primary-itf = "wlp3s0"; }
  ];
  zramSwap.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = true;
  boot.tmp.useTmpfs = true;
  services.fwupd.enable = true;
  programs.light.enable = true;
}
