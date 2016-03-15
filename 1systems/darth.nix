{ config, pkgs, lib, ... }:

with config.krebs.lib;
{
  imports = [
        ../2configs/fs/single-partition-ext4.nix
        ../2configs/zsh-user.nix
        ../.
  ];

  krebs.retiolum.enable = true;

  boot.loader.grub.device = "/dev/disk/by-id/ata-ADATA_SSD_S599_64GB_10460000000000000039";
  users.users.root.openssh.authorizedKeys.keys = [
    config.krebs.users.makefu-omo.pubkey
  ];
}
