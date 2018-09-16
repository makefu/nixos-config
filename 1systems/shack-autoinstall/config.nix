{ config, pkgs, lib, ... }:

with import <stockholm/lib>;
let
  disk = "/dev/sda";
in {
  imports = [
    <stockholm/makefu>
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    <stockholm/makefu/2configs/tools/core.nix>
  ];
  # TODO: NIX_PATH and nix.nixPath are being set by default.nix right now
  # cd ~/stockholm ; nix-build -A config.system.build.isoImage -I nixos-config=makefu/1systems/iso.nix -I secrets=/home/makefu/secrets/iso /var/src/nixpkgs/nixos
  krebs.build.host = config.krebs.hosts.iso;
  krebs.hidden-ssh.enable = true;

  environment.extraInit = ''
    EDITOR=vim
  '';
  # iso-specific
  boot.kernelParams = [ "copytoram" ];


  environment.systemPackages = [
    pkgs.parted
    (  pkgs.writeScriptBin "shack-install" ''
      #! /bin/sh
      echo "go ahead and try NIX_PATH=/root/.nix-defexpr/channels/ nixos-install"
    '')
  ];

  systemd.services.wpa_supplicant.wantedBy = lib.mkForce [ "multi-user.target" ];

  networking.wireless = {
    enable = true;
    networks.shack.psk = "welcome2shack";
  };


  services.openssh = {
    enable = true;
    hostKeys = [
      { bits = 8192; type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
    ];
  };
  # enable ssh in the iso boot process
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
}
