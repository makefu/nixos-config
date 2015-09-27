#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/base.nix
      ../2configs/main-laptop.nix #< base-gui

      # configures sources
      ../2configs/base-sources.nix

      # Krebs
      ../2configs/tinc-basic-retiolum.nix
      #../2configs/disable_v6.nix

      # environment
      ../2configs/zsh-user.nix

      # applications
      ../2configs/exim-retiolum.nix
      #../2configs/virtualization.nix
      ../2configs/virtualization-virtualbox.nix
      ../2configs/wwan.nix

      # services
      ../2configs/git/brain-retiolum.nix
      ../2configs/tor.nix

      # hardware specifics are in here
      ../2configs/hw/tp-x220.nix
      # mount points
      ../2configs/fs/sda-crypto-root-home.nix
    ];
  krebs.Reaktor.enable = true;
  krebs.Reaktor.debug = true;
  krebs.Reaktor.nickname = "makefu|r";

  krebs.build.host = config.krebs.hosts.pornocauster;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@pornocauster";


  networking.firewall.allowedTCPPorts = [
    25
  ];

}
