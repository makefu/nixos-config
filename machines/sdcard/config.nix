{ config, pkgs, lib, ... }:
let
  kernel = pkgs.callPackage ./kernel.nix {
      kernelPatches = with pkgs.kernelPatches; [
      #  kernelPatches.bridge_stp_helper
      #  kernelPatches.modinst_arg_list_too_long
      ];
    };
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
    # <stockholm/makefu/2configs/minimal.nix>
  ];
  # TODO: NIX_PATH and nix.nixPath are being set by default.nix right now
  # cd ~/stockholm ; nix build config.system.build.sdImage -I  nixos-config=makefu/1systems/sdcard/config.nix -f /home/makefu/nixpkgs/nixos

  boot.kernelParams = ["console=ttyS2,1500000" "earlycon=uart8250,mmio32,0xff1a0000"];
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackagesFor kernel;
  boot.supportedFilesystems = lib.mkForce [ "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  # krebs.hidden-ssh.enable = true;
  environment.systemPackages = with pkgs; [
    aria2
    ddrescue
  ];
  environment.extraInit = ''
    EDITOR=vim
  '';
  # iso-specific
  services.openssh = {
    enable = true;
    hostKeys = [
      { bits = 8192; type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
    ];
  };
  # enable ssh in the iso boot process
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
}
