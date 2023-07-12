{ config, lib, pkgs, ... }:

let
  mpds = import ./mpdconfig.nix;
  systemd_mpd = name: value: let
    path = "/var/lib/mpd-${name}";
    num = lib.strings.fixedWidthNumber 2 value;
    mpdconf = pkgs.writeText "mpd-config-${name}" ''
      music_directory     "${path}/music"
      playlist_directory  "${path}/playlists"
      db_file             "${path}/tag_cache"
      state_file          "${path}/state"
      sticker_file        "${path}/sticker.sql"

      bind_to_address "127.0.0.1"
      port "66${num}"
      log_level "default"
      auto_update "yes"
      audio_output {
        type "httpd"
        name "Office Radio ${num} - ${name}"
        encoder "vorbis" # optional
        port "280${num}"
        quality "5.0" # do not define if bitrate is defined
        # bitrate "128" # do not define if quality is defined
        format "44100:16:2"
        always_on "yes" # prevent MPD from disconnecting all listeners when playback is stopped.
        tags "yes" # httpd supports sending tags to listening streams.
      }
    '';
in {
    after = [ "network.target" ];
    description = "Office Radio MPD ${toString value} - ${name}";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
        #User = "mpd";
        DynamicUser = true;
        ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon ${mpdconf}";
        LimitRTPRIO = 50;
        LimitRTTIME = "infinity";
        ProtectSystem = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
        RestrictNamespaces = true;
        Restart = "always";
        StateDirectory = [ "mpd-${name}" ];
      };
  };
in
  {
    systemd.services = lib.attrsets.mapAttrs' (name: value:
      lib.attrsets.nameValuePair
        ("office-radio-" +name) (systemd_mpd name value))
      mpds;
  }
