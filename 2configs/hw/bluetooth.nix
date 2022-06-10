{ pkgs, ... }:
{ # bluetooth+pulse config
# for blueman-applet
  users.users.makefu.packages = [ pkgs.blueman ];
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
# systemWide = true;
    support32Bit = true;
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
      load-module module-switch-on-connect
      load-module module-switch-on-port-available
      '';
  };
  services.blueman.enable = true;
# presumably a2dp Sink
# Enable profile:
## pacmd set-card-profile "$(pactl list cards short | egrep -o bluez_card[[:alnum:]._]+)" a2dp_sink

# connect via https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings.general.Enable = "Source,Sink,Media,Socket";
  };
  services.dbus.packages = [ pkgs.blueman ];
}
