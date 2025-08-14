{ config,nixos-hardware, lib, pkgs, ... }:

{

  imports = [ ./tp-x2x0.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
];

  # configured media keys inside awesomerc
  # sound.mediaKeys.enable = true;

  # possible i915 powersave options:
  #  options i915 enable_rc6=1 enable_fbc=1 semaphores=1

  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
    options i915 enable_rc6=1 enable_fbc=1 semaphores=1
  '';

  boot.initrd.availableKernelModules = [ "thinkpad_acpi" ];

  services.xserver.displayManager.sessionCommands =''
    xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
    xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
    # xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 8 200
  '';

  # load graphical equalizer module
  # load-module module-equalizer-sink

  # combine multiple sinks to one:
  # list all sinks: pactl list short sinks
  # pacmd load-module module-combine-sink sink_name=combined sink_properties=device.description=CombinedSink slaves=sink1,sink2 channels=2

}
