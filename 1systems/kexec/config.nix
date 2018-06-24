{ config, pkgs, lib, ... }:

with import <stockholm/lib>;
{
  imports = [
    <stockholm/makefu>
    # <stockholm/makefu/2configs/tools/core.nix>
    <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
    <clever_kexec/kexec/kexec.nix>
  ];
  # cd ~/stockholm ; nix-build '<nixpkgs/nixos>' -A config.system.build.kexec_tarball -j 4 -I nixos-config=makefu/1systems/iso.nix -I secrets=/home/makefu/secrets/iso

  krebs.build.host = config.krebs.hosts.iso;
  krebs.hidden-ssh.enable = true;
  environment.extraInit = ''
    EDITOR=vim
  '';
  services.openssh = {
    enable = true;
    hostKeys = [
      { bits = 8192; type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
    ];
  };
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
}
