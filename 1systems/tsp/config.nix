#
#
#
{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <stockholm/makefu>
      <stockholm/makefu/2configs/main-laptop.nix>
      # <stockholm/makefu/2configs/tools/all.nix>
      <stockholm/makefu/2configs/fs/single-partition-ext4.nix>
      # hardware specifics are in here
      # imports tp-x2x0.nix
      <stockholm/makefu/2configs/hw/tp-x230.nix>
      <stockholm/makefu/2configs/hw/bluetooth.nix>
      <stockholm/makefu/2configs/hw/network-manager.nix>

      # <stockholm/makefu/2configs/rad1o.nix>

      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>

      <stockholm/makefu/2configs/sshd-totp.nix>
      {
        programs.adb.enable = true;
      }
    ];
  krebs.build.host = config.krebs.hosts.tsp;
  boot.loader.grub.device = "/dev/sda";

  networking.firewall.allowedTCPPorts = [
    25
  ];

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
}
