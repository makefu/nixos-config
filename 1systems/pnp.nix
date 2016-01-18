# Usage:
#  NIX_PATH=secrets=/home/makefu/secrets/wry:nixpkgs=/var/src/nixpkgs  nix-build -A users.makefu.pnp.config.system.build.vm
#  result/bin/run-pnp-vm -virtfs local,path=/home/makefu/secrets/pnp,security_model=none,mount_tag=secrets
{ config, pkgs, ... }:

{
  imports =
    [
      ../2configs/tinc-basic-retiolum.nix
      ../2configs/headless.nix
      ../../krebs/3modules/Reaktor.nix

      # these will be overwritten by qemu-vm.nix but will be used if the system
      # is directly deployed
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      ../2configs/fs/vm-single-partition.nix

      # config.system.build.vm
      <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
    ];

  virtualisation.graphics = false;
  # also export secrets, see Usage above
  fileSystems = pkgs.lib.mkVMOverride {
    "${builtins.toString <secrets>}" =
      { device = "secrets";
        fsType = "9p";
        options = "trans=virtio,version=9p2000.L,cache=loose";
        neededForBoot = true;
      };
  };

  krebs.Reaktor = {
    enable = true;
    debug = true;
    extraEnviron = {
      REAKTOR_HOST = "cd.retiolum";
    };
    plugins = with pkgs.ReaktorPlugins; [ stockholm-issue nixos-version sed-plugin ];
    channels = [ "#retiolum" ];
  };

  krebs.build.host = config.krebs.hosts.pnp;

  nixpkgs.config.packageOverrides = pkgs: { tinc = pkgs.tinc_pre; };

  networking.firewall.allowedTCPPorts = [
  25
  ];

}
