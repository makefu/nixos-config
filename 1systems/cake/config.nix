{ config, lib, pkgs, ... }:
let
  primaryInterface = "eth0";
in {
  imports = [
    <stockholm/makefu>
    ./hardware-config.nix
    <stockholm/makefu/2configs/home-manager>
    <stockholm/makefu/2configs/home/3dprint.nix>
    #./hardware-config.nix
    { environment.systemPackages = with pkgs;[ rsync screen curl git tmux picocom mosh ];}
    # <stockholm/makefu/2configs/tools/core.nix>
    <stockholm/makefu/2configs/binary-cache/nixos.nix>
    #<stockholm/makefu/2configs/support-nixos.nix>
    # <stockholm/makefu/2configs/homeautomation/default.nix>
    # <stockholm/makefu/2configs/homeautomation/google-muell.nix>
    # configure your hw:
    # <stockholm/makefu/2configs/save-diskspace.nix>
  ];
  krebs = {
    enable = true;
    tinc.retiolum.enable = true;
    build.host = config.krebs.hosts.cake;
  };
  # ensure disk usage is limited
  services.journald.extraConfig = "Storage=volatile";
  networking.firewall.trustedInterfaces = [ primaryInterface ];
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
  sound.enable = false;
}
