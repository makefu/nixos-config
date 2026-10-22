{ config, lib, pkgs, ... }:
let
  primaryInterface = "end0";
in {
  imports = [
    ./hardware-config.nix
    ../../2configs
    ../../2configs/home-manager
    ../../2configs/home/zigbee/cake.nix
    #./hardware-config.nix
    { environment.systemPackages = with pkgs;[ rsync screen curl git tmux picocom mosh ];}
    # ../../2configs/tools/core.nix
    ../../2configs/binary-cache/nixos.nix
    #../../2configs/support-nixos.nix
    # ../../2configs/homeautomation/default.nix
    # ../../2configs/homeautomation/google-muell.nix
    #../../2configs/hw/pseyecam.nix
    # configure your hw:
    # ../../2configs/save-diskspace.nix

    # directly use the alsa device instead of attaching to pulse

    ../../2configs/tinc/retiolum.nix
    # ../../2configs/audio/respeaker.nix
    #../../2configs/home/rhasspy/default.nix
    #../../2configs/home/rhasspy/led-control.nix
  ];
  # cake.euer (the clan default target) does not resolve; reach it over the
  # tinc retiolum name instead. ICMP is filtered but ssh works.
  clan.core.networking.targetHost = "root@cake.r";
  # 3.7G RAM, 4 cores, no disk swap: the vendor rpi kernel build OOM-killed
  # cc1 at -j4 (ice_common.o). zram gives compressed swap at RAM speed, and
  # limiting nix's build cores keeps concurrent cc1 processes bounded.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
  boot.kernel.sysctl = {
    # Default 60 is tuned for spinning rust; zram is RAM speed.
    "vm.swappiness" = 150;
    # Swap-in readahead is pointless when the device is RAM.
    "vm.page-cluster" = 0;
  };
  nix.settings = {
    cores = 2;
    max-jobs = 2;
  };
  # ensure disk usage is limited
  services.journald.storage = "volatile";
  networking.firewall.trustedInterfaces = [ primaryInterface ];
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
  #nixpkgs.config.allowUnsupportedSystem = true;
}
