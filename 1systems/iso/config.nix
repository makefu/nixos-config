{ config, pkgs, lib, ... }:

with import <stockholm/lib>;
{
  imports = [
    #<stockholm/makefu>
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    # <stockholm/makefu/2configs/tools/core.nix>
    ./justdoit.nix
    {
      environment.systemPackages = [ (pkgs.writeScriptBin "network-setup" ''
        #!/bin/sh
        ip addr add  178.254.30.202/255.255.252.0 dev ens3
        ip route add default via 178.254.28.1
        echo nameserver 1.1.1.1 > /etc/resolv.conf
      '')];
      kexec.justdoit = {
        bootSize = 512;
        rootDevice = "/dev/vda";
        bootType = "vfat";
        luksEncrypt = false;
        uefi = false;
      };
    }
  ];
  # boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  # TODO: NIX_PATH and nix.nixPath are being set by default.nix right now
  # cd ~/stockholm ; nix-build -A config.system.build.isoImage -I nixos-config=makefu/1systems/iso/config.nix -I secrets=/home/makefu/secrets/iso /var/src/nixpkgs/nixos
  #krebs.build.host = { cores = 0; };
  isoImage.isoBaseName = lib.mkForce "stockholm";
  #krebs.hidden-ssh.enable = true;
  # environment.systemPackages = with pkgs; [
  #   aria2
  #   ddrescue
  # ];
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
  # hack `tee` behavior
  nixpkgs.config.packageOverrides = super: {
    irc-announce = super.callPackage <stockholm/krebs/5pkgs/simple/irc-announce> {
      pkgs = pkgs // {
        coreutils = pkgs.symlinkJoin {
          name =  "coreutils-hack";
          paths = [
            pkgs.coreutils
            (pkgs.writeDashBin "tee" ''
              if test "$1" = /dev/stderr; then
                while read -r line; do
                  echo "$line"
                  echo "$line" >&2
                done
              else
                ${super.coreutils}/bin/tee "$@"
              fi
            '')
          ];
        };
      };
    };
  };
}
