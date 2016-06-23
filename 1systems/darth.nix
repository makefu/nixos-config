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
      ../2configs/exim-retiolum.nix
      ../2configs/virtualization.nix
  ];
  services.tinc.networks.siem = {
    name = "sdarth";
    extraConfig = "ConnectTo = sjump";
  };
  #networking.firewall.enable = false;
  krebs.retiolum.enable = true;

  boot.kernelModules = [ "coretemp" "f71882fg" ];

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  networking = {
    wireless.enable = true;
    firewall = {
      allowPing = true;
      logRefusedConnections = false;
      allowedUDPPorts = [ 80 655 1655 67 ];
      allowedTCPPorts = [ 80 655 1655 ];
    };
    # fallback connection to the internal virtual network
    interfaces.virbr3.ip4 =  [{
      address = "10.8.8.2";
      prefixLength = 24;
    }];
  };

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
