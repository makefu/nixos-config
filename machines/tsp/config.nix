{ config, pkgs, lib, self, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
      ../../2configs/default.nix
            # ../../2configs/nur.nix

      # ../../2configs/nur.nix
      ../../2configs/home-manager
      ../../2configs/main-laptop.nix
      ../../2configs/editor/neovim
      ../../2configs/tools/core.nix
      # ../../2configs/tools/all.nix

      ((import  ../../2configs/fs/disko/single-disk-encrypted-zfs.nix ) { disk = "/dev/sda"; hostId = "f8b8e0a2"; })
      # hardware specifics are in here
      ../../2configs/hw/bluetooth.nix
      ../../2configs/hw/network-manager.nix


      # ../../2configs/rad1o.nix

      ../../2configs/zsh
      ../../2configs/home-manager
      ../../2configs/home-manager/desktop.nix
      ../../2configs/home-manager/cli.nix

      # still broken
      # ../../2configs/tinc/retiolum.nix
      # ../../2configs/sshd-totp.nix
    ];

  nixpkgs.config.allowUnfree = true;
  krebs.build.host = config.krebs.hosts.tsp;
}
