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
      ../2configs/graphite-standalone.nix
      ../2configs/vm-single-partition.nix
      ../2configs/tinc-basic-retiolum.nix
    ];
  krebs.build.host = config.krebs.hosts.pnp;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@pnp";

  krebs.build.deps = {
    nixpkgs = {
      url = https://github.com/NixOS/nixpkgs;
      rev = "4c01e6d91993b6de128795f4fbdd25f6227fb870";
    };
  };

  networking.firewall.allowedTCPPorts = [
  # nginx runs on 80
  # graphite-web runs on 8080, carbon cache runs on 2003 tcp and udp
    80
    8080 2003
  ];
  networking.firewall.allowedUDPPorts = [ 2003 ];

}
