{ config, pkgs, ... }:
let
  pulse = pkgs.pulseaudioFull;
  user = config.makefu.gui.user;
  wait_time = 30;
in
{
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pulse;
  };

  environment.systemPackages = with pkgs; [
    jack2Full
    jack_capture
  ];
  # from http://anderspapitto.com/posts/2015-11-26-overtone-on-nixos-with-jack-and-pulseaudio.html

  systemd.user.services = {
    jackdbus = {
      description = "Runs jack, and points pulseaudio at it";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "start_jack.sh" ''
          #! ${pkgs.bash}/bin/bash
          . ${config.system.build.setEnvironment}

          # TODO: correctly wait for pulseaudio, cannot use pulseaudio.service
          sleep ${toString wait_time} # wait for the gui to load

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
        Restart = "always";
        RestartSec = "5";
      };
      after = [ "display-manager.service" "sound.target" ];
      wantedBy = [ "default.target" ];
    };
  };
}
