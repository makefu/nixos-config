# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../.
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      ../2configs/cgit-retiolum.nix
    ];
  krebs.build.host = config.krebs.hosts.repunit;

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
