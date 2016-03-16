{ config, pkgs, lib, ... }:

with config.krebs.lib;
let
  byid = dev: "/dev/disk/by-id/" + dev;
  rootDisk = byid "ata-ADATA_SSD_S599_64GB_10460000000000000039";
  auxDisk = byid "ata-HGST_HTS721010A9E630_JR10006PH3A02F";
  dataPartition = auxDisk + "-part1";

  allDisks = [ rootDisk auxDisk ];
in {
  imports = [
        ../.
        ../2configs/fs/single-partition-ext4.nix
        ../2configs/zsh-user.nix
        ../2configs/smart-monitor.nix
  ];

  # virtualisation.nova.enableSingleNode = true;
  krebs.retiolum.enable = true;

  # TODO smartd omo darth gum all-in-one
  services.smartd.devices = builtins.map (x: { device = x; }) allDisks;
  zramSwap.enable = true;

  fileSystems."/data" = {
    device = dataPartition;
    fsType = "ext4";
  };

  boot.loader.grub.device = rootDisk;

  users.users.root.openssh.authorizedKeys.keys = [
    config.krebs.users.makefu-omo.pubkey
    config.krebs.users.makefu-vbob.pubkey
  ];

  krebs.build.host = config.krebs.hosts.darth;
}
