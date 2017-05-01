{ config, pkgs, lib, ... }:

with import <stockholm/lib>;
{
  imports = [
    ../.
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ../2configs/tools/core.nix
  ];
  # TODO: NIX_PATH and nix.nixPath are being set by default.nix right now
  # cd ~/stockholm ; nix-build -A config.system.build.isoImage -I nixos-config=makefu/1systems/iso.nix -I secrets=/home/makefu/secrets/iso /var/src/nixpkgs/nixos
  krebs.build.host = config.krebs.hosts.iso;
  krebs.hidden-ssh.enable = true;
  environment.systemPackages = with pkgs; [
    aria2
    ddrescue
  ];
  environment.extraInit = ''
    EDITOR=vim
  '';
  # iso-specific
  boot.kernelParams = [ "copytoram" ];
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
    irc-announce = super.callPackage <stockholm/krebs/5pkgs/irc-announce> {
      pkgs = pkgs // { coreutils = pkgs.concat "coreutils-hack" [
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
      ];};
    };
  };
}
