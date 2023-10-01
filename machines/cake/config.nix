{ config, lib, pkgs, ... }:
let
  primaryInterface = "eth0";
in {
  imports = [
    ./hardware-config.nix
    ../../2configs
    ../../2configs/home-manager
    ../../2configs/home/3dprint.nix
    #./hardware-config.nix
    { environment.systemPackages = with pkgs;[ rsync screen curl git tmux picocom mosh ];}
    # ../../2configs/tools/core.nix
    ../../2configs/binary-cache/nixos.nix
    #../../2configs/support-nixos.nix
    # ../../2configs/homeautomation/default.nix
    # ../../2configs/homeautomation/google-muell.nix
    # ../../2configs/hw/pseyecam.nix
    # configure your hw:
    # ../../2configs/save-diskspace.nix

    # directly use the alsa device instead of attaching to pulse

    ../../2configs/tinc/retiolum.nix
    ../../2configs/audio/respeaker.nix
    ../../2configs/home/rhasspy/default.nix
    ../../2configs/home/rhasspy/led-control.nix
  ];
  krebs = {
    enable = true;
    build.host = config.krebs.hosts.cake;
  };
  # ensure disk usage is limited
  services.journald.extraConfig = "Storage=volatile";
  networking.firewall.trustedInterfaces = [ primaryInterface ];
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
}
