{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{

  imports = [ ./tp-x2x0.nix  <nixos-hardware/lenovo/thinkpad/x230> ];

  # configured media keys inside awesomerc
  # sound.mediaKeys.enable = true;

  # possible i915 powersave options:
  #  options i915 enable_rc6=1 enable_fbc=1 semaphores=1

  services.xserver.displayManager.sessionCommands =''
    xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
    xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
    # xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 8 200
  '';

  # enable HDMI output switching with pulseaudio
  hardware.pulseaudio.extraConfig = ''
    load-module module-alsa-sink device=hw:0,3 sink_properties=device.description="HDMIOutput" sink_name="HDMI"
  '';
  # load graphical equalizer module
  # load-module module-equalizer-sink

  # combine multiple sinks to one:
  # list all sinks: pactl list short sinks
  # pacmd load-module module-combine-sink sink_name=combined sink_properties=device.description=CombinedSink slaves=sink1,sink2 channels=2

}
