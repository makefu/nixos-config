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
    # pipewire workaround for mpd to play music on kiosk user
    systemd.services.mpd.environment = {
      # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
      XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.kiosk.uid}";
    };
    services.mpd = {
      enable = true;
      inherit (cfg) musicDirectory;
      network.listenAddress = "any";
      user = "kiosk"; # run mpd under pipewire user
      startWhenNeeded = true;
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "pipewire output"
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

    # connect via https://wiki.nixos.org/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    hardware.bluetooth.enable = true;
    environment.etc."bluetooth/audio.conf".text = ''
      [General]
      Enable = Source,Sink,Media,Socket
    '';
  };
}
