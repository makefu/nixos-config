{ config, lib, pkgs, ... }:

# stuff for the main laptop
# this is pretty much nice-to-have and does
# not fit into base-gui
# TODO split generic desktop stuff and laptop-specifics like lidswitching

with config.krebs.lib;
{
  imports = [
    ./base-gui.nix
    ./fetchWallpaper.nix
    ./zsh-user.nix
    ./laptop-utils.nix
  ];

  users.users.${config.krebs.build.user.name}.extraGroups = [ "dialout" ];

  krebs.power-action = let
    speak = "${pkgs.espeak}/bin/espeak";
    whisper = text: ''${pkgs.espeak}/bin/espeak -v +whisper -s 110 "${text}"'';
    note = "${pkgs.libnotify}/bin/notify-send";
  in {
    enable = true;
    plans.low-battery = {
      upperLimit = 25;
      lowerLimit = 15;
      charging = false;
      action = whisper "power level low, please plug me in";
    };
    plans.nag-harder = {
      upperLimit = 15;
      lowerLimit = 5;
      action = pkgs.writeDash "crit-speak" ''
        ${whisper "Power level critical, do something"}
        ${note} Battery -u critical -t 600000 "Power level critical, do something!"
      '';
    };
    plans.last-chance = {
      upperLimit = 5;
      lowerLimit = 3;
      charging = false;
      action = pkgs.writeDash "suspend-wrapper" ''
        ${note} Battery -u crit "You've had your chance, suspend in 5 seconds"
        ${concatMapStringsSep "\n" (i: ''
            ${note} -u critical -t 1000 ${toString i}
            ${speak} ${toString i} &
            sleep 1
          '')
          [ 5 4 3 2 1 ]}
        /var/setuid-wrappers/sudo ${pkgs.systemd}/bin/systemctl suspend
      '';
    };
  };
  users.users.power-action.extraGroups = [ "audio" ];
  security.sudo.extraConfig = "${config.krebs.power-action.user.name} ALL= (root) NOPASSWD: ${pkgs.systemd}/bin/systemctl suspend";

  services.redshift = {
    enable = true;
    latitude = "48.7";
    longitude = "9.1";
  };

}
