{ config, lib, pkgs, ... }:

# vda1 ext4 (label nixos) -> only root partition
with pkgs.stockholm.lib;
{
  imports = [
    ./single-partition-ext4.nix
  ];
  boot.loader.grub.device = "/dev/vda";

}
