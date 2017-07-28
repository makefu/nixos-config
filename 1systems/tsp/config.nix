#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <stockholm/makefu>
      <stockholm/makefu/2configs/gui/base.nix>
      <stockholm/makefu/2configs/fs/sda-crypto-root.nix>
      # hardware specifics are in here
      # imports tp-x2x0.nix
      <stockholm/makefu/2configs/hw/tp-x200.nix>

      <stockholm/makefu/2configs/disable_v6.nix>
      <stockholm/makefu/2configs/rad1o.nix>

      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>
    ];
  # not working in vm
  krebs.build.host = config.krebs.hosts.tsp;

  networking.firewall.allowedTCPPorts = [
    25
  ];

}
