# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      ../2configs/base.nix
      ../2configs/cgit-retiolum.nix
    ];
  krebs.build.host = config.krebs.hosts.repunit;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@repunit";

  krebs.build.deps = {
    nixpkgs = {
      url = https://github.com/NixOS/nixpkgs;
      rev = "4c01e6d91993b6de128795f4fbdd25f6227fb870";
    };
    secrets = {
      url = "/home/makefu/secrets/${config.krebs.build.host.name}";
    };
    stockholm = {
      url = toString ../..;
    };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "ehci_pci" "virtio_pci" "virtio_blk" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

# networking.firewall is enabled by default
  networking.firewall.allowedTCPPorts = [ 80 ];
  networking.firewall.allowPing = true;

  fileSystems."/" =
  { device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
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

# $ nix-env -qaP | grep wget
    environment.systemPackages = with pkgs; [
      jq
    ];
}
