{ config, lib, pkgs, ... }:
let
  primaryInterface = "eth0";
in {
  imports = [
    <stockholm/makefu>
    ./hardware-config.nix
    <stockholm/makefu/2configs/home-manager>
    <stockholm/makefu/2configs/tools/core.nix>
    <stockholm/makefu/2configs/binary-cache/nixos.nix>

    <stockholm/makefu/2configs/home/rhasspy>
    # <stockholm/makefu/2configs/hw/pseyecam.nix>
  ];
  krebs = {
    enable = true;
    tinc.retiolum.enable = true;
    build.host = config.krebs.hosts.snake;
  };
  # ensure disk usage is limited
  services.journald.extraConfig = "Storage=volatile";
  networking.firewall.trustedInterfaces = [ primaryInterface ];
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
}
