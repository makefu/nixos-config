#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../.
      ../2configs/base-gui.nix
      ../2configs/fs/sda-crypto-root.nix
      # hardware specifics are in here
      ../2configs/hw/tp-x200.nix #< imports tp-x2x0.nix

      ../2configs/disable_v6.nix
      ../2configs/rad1o.nix

      ../2configs/zsh-user.nix
      ../2configs/exim-retiolum.nix
    ];
  # not working in vm
  krebs.retiolum.enable = true;
  krebs.build.host = config.krebs.hosts.tsp;

  networking.firewall.allowedTCPPorts = [
    25
  ];

}
