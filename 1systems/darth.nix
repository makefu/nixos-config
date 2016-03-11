{ config, pkgs, lib, ... }:

with config.krebs.lib;
{
  imports = [
        ../2configs/fs/single-partition-ext4.nix
        ../2configs/zsh-user.nix
        ../.
  ];

  krebs.build.host = config.krebs.hosts.darth;
  krebs.retiolum.enable = true;
  nixpkgs.config.packageOverrides = pkgs: { tinc = pkgs.tinc_pre; };

  boot.loader.grub.device = "/dev/disk/by-id/ata-ADATA_SSD_S599_64GB_10460000000000000039";
  users.users.root.openssh.authorizedKeys.keys = [
    config.krebs.users.makefu-omo.pubkey
  ];
}
