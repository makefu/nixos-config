{ config, lib, pkgs, ... }:
{
  imports = [
    <stockholm/makefu>
    ./hardware-config.nix
    <stockholm/makefu/2configs/tools/core.nix>
# configure your hw:
# <stockholm/makefu/2configs/save-diskspace.nix>
  ];
  krebs = {
    enable = true;
    tinc.retiolum.enable = true;
    build.host = config.krebs.hosts.cake;
  };

  documentation.info.enable = false;
  documentation.man.enable = false;
  services.nixosManual.enable = false;
  sound.enable = false;

}
