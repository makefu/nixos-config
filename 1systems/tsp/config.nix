{ config, pkgs, lib, self, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
      ../../2configs/default.nix
            # (self + "/2configs/nur.nix")

      # (self + "/2configs/nur.nix")
      (self + "/2configs/home-manager")
      (self + "/2configs/main-laptop.nix")
      (self + "/2configs/editor/neovim")
      (self + "/2configs/tools/core.nix")
      # (self + "/2configs/tools/all.nix")
      (self + "/2configs/fs/disko/single-disk-bcachefs.nix")
      # hardware specifics are in here
      (self + "/2configs/hw/bluetooth.nix")
      (self + "/2configs/hw/network-manager.nix")


      # (self + "/2configs/rad1o.nix")

      (self + "/2configs/zsh-user.nix")
      (self + "/2configs/home-manager")
      (self + "/2configs/home-manager/desktop.nix")
      (self + "/2configs/home-manager/cli.nix")

      # still broken
      #(self + "/2configs/tinc/retiolum.nix")
      # (self + "/2configs/sshd-totp.nix")
    ];

  nixpkgs.config.allowUnfree = true;
}
