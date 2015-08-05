# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/base.nix
      ../2configs/base-gui.nix
    ];
  # not working in vm
  #services.xserver = {
  #  videoDriver = "intel";
  #};
  krebs.build.host = config.krebs.hosts.tsp;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@tsp";

  krebs.build.deps = {
    nixpkgs = {
      #url = https://github.com/NixOS/nixpkgs;
      url = https://github.com/makefu/nixpkgs;
      #rev = "4c01e6d91993b6de128795f4fbdd25f6227fb870";
      rev = "08275910ba86ed9bd7a2608e6a1e5285faf24cb2";
    };
    # TODO generalize in base.nix
    secrets = {
      url = "/home/makefu/secrets/${config.krebs.build.host.name}";
    };
    # TODO generalize in base.nix
    stockholm = {
      url = toString ../..;
    };
  };

  krebs.retiolum = {
    enable = true;
    hosts = ../../Zhosts;
    connectTo = [
      "gum"
      "pigstarter"
      "fastpoke"
    ];
  };

  boot = {
    #x200 specifics
    kernelModules = [ "tp_smapi" "msr" ];
    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

    loader.grub.enable =true;
    loader.grub.version =2;
    loader.grub.device = "/dev/sda";

    # crypto boot
    # TODO: use UUID
    initrd.luks.devices = [ { name = "luksroot"; device= "/dev/sda2";}];
    initrd.luks.cryptoModules = ["aes" "sha512" "sha1" "xts" ];
    initrd.availableKernelModules = ["xhci_hcd" "ehci_pci" "ahci" "usb_storage" ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/luksroot";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/nixboot";
      fsType = "ext4";
    };
  };

  # hardware specifics
  networking.wireless.enable = true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  # TODO: generalize to numCPU + 1
  nix.maxJobs = 3;


  networking.firewall.rejectPackets = true;
  networking.firewall.allowPing = true;


  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    jq
  ];
}
