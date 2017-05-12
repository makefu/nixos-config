{ config, pkgs, ... }:
let
  pulse = pkgs.pulseaudioFull;
  user = config.makefu.gui.user;
in
{
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pulse;
  };

  environment.systemPackages = with pkgs; [ jack2Full ];
  # from http://anderspapitto.com/posts/2015-11-26-overtone-on-nixos-with-jack-and-pulseaudio.html

  systemd.services = {
    jackdbus = {
      description = "Runs jack, and points pulseaudio at it";
      serviceConfig = {
        User = user;
        Type = "oneshot";
        ExecStart = pkgs.writeScript "start_jack.sh" ''
          #! ${pkgs.bash}/bin/bash
          . ${config.system.build.setEnvironment}
          sleep 5 # wait for the gui to load

          ${pkgs.jack2Full}/bin/jack_control start
          sleep 3 # give some time for sources/sinks to be created

          ${pulse}/bin/pacmd set-default-sink jack_out
          ${pulse}/bin/pacmd set-default-source jack_in
        '';
        ExecStop = pkgs.writeScript "stop_jack.sh" ''
          #! ${pkgs.bash}/bin/bash
          . ${config.system.build.setEnvironment}

          ${pkgs.jack2Full}/bin/jack_control stop
        '';
        RemainAfterExit = true;
      };
      after = [ "display-manager.service" "sound.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
