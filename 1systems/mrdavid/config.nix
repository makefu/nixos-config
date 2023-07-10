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

      ((import  ../../2configs/fs/disko/single-disk-ext4.nix ) { disk = "/dev/sda"; })
      # hardware specifics are in here

      ../../2configs/zsh-user.nix
      ../../2configs/home-manager
      ../../2configs/home-manager/desktop.nix
      ../../2configs/home-manager/cli.nix

      # ../../2configs/tinc/retiolum.nix
    ];

  nixpkgs.config.allowUnfree = true;
}
