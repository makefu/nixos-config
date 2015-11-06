# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      # Base
      ../2configs/tinc-basic-retiolum.nix
      ../2configs/headless.nix

      # HW/FS

      # enables virtio kernel modules in initrd
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      ../2configs/fs/vm-single-partition.nix

      # Services
      ../2configs/git/cgit-retiolum.nix

      ## Reaktor
      ## \/ are only plugins, must enable Reaktor explicitly
      ../2configs/Reaktor/stockholmLentil.nix
      ../2configs/Reaktor/simpleExtend.nix
      ../2configs/Reaktor/random-emoji.nix
      ../2configs/Reaktor/titlebot.nix
      ../2configs/Reaktor/shack-correct.nix

      ../2configs/exim-retiolum.nix
      ../2configs/urlwatch.nix

      # ../2configs/graphite-standalone.nix
    ];
  krebs.urlwatch.verbose = true;

  krebs.Reaktor.enable = true;
  krebs.Reaktor.debug = true;
  krebs.Reaktor.nickname = "Reaktor|bot";
  krebs.Reaktor.extraEnviron = {
    REAKTOR_CHANNELS = "#krebs,#binaergewitter,#shackspace";
  };

  krebs.build.host = config.krebs.hosts.pnp;

  nixpkgs.config.packageOverrides = pkgs: { tinc = pkgs.tinc_pre; };


  networking.firewall.allowedTCPPorts = [
  # nginx runs on 80
  80
  # graphite-web runs on 8080, carbon cache runs on 2003 tcp and udp
  # 8080 2003

  # smtp
  25
  ];

  # networking.firewall.allowedUDPPorts = [ 2003 ];

}
