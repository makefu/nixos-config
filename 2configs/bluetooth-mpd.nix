{ pkgs, config, lib, ... }:

let
  cfg = config.makefu.mpd;
in {
  options.makefu.mpd.musicDirectory = lib.mkOption {
    description = "music Directory";
    default = "/data/music";
    type = lib.types.str;
  };
  config = {
    services.mpd = {
      enable = true;
      inherit (cfg) musicDirectory;
      network.listenAddress = "0.0.0.0";
      extraConfig = ''
        audio_output {
          type    "pulse"
          name    "Local MPD"
          server  "127.0.0.1"
        }
      '';
    };
  # open because of truestedInterfaces
  # networking.firewall.allowedTCPPorts = [ 6600 4713 ];
    services.samba.shares.music = {
      path = cfg.musicDirectory;
      "read only" = "no";
      browseable = "yes";
      "guest ok" = "yes";
    };

    sound.enable = true;
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
  # systemWide = true;
      support32Bit = true;
      zeroconf.discovery.enable = true;
      zeroconf.publish.enable = true;
      tcp = {
        enable = true;
        # PULSE_SERVER=192.168.1.11 pavucontrol
        anonymousClients.allowAll = true;
        # anonymousClients.allowedIpRanges =  [ "127.0.0.1" ];
      };
      configFile = pkgs.writeText "default.pa" ''
        load-module module-udev-detect
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
        load-module module-native-protocol-unix
        load-module module-always-sink
        load-module module-console-kit
        load-module module-systemd-login
        load-module module-intended-roles
        load-module module-position-event-sounds
        load-module module-filter-heuristics
        load-module module-filter-apply
        # will be enabled by pulseaudio.tcp.enable
        # load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
        load-module module-switch-on-connect
        # may be required for "system-wide" pulse to connect to bluetooth
        #module-bluez5-device
        #module-bluez5-discover
      '';
    };
  # connect via https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    hardware.bluetooth.enable = true;
  #hardware.bluetooth.extraConfig = ''
  #  [general]
  #  Enable=Source,Sink,Media,Socket
  #'';
  };
}
