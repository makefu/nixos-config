{ config, lib, pkgs, ... }:

with config.krebs.lib;
{

  imports = [ ./tp-x2x0.nix ];
  boot = {
    kernelModules = [ "kvm-intel" "acpi_call" ];
    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];
  };

  services.xserver = {
    videoDriver = "intel";
    vaapiDrivers = [ pkgs.vaapiIntel pkgs.vaapiVdpau ];
    deviceSection = ''
      Option "AccelMethod" "sna"
    '';
  };

  security.rngd.enable = true;

  services.xserver.displayManager.sessionCommands =''
    xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
    xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
    # xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 8 200
  '';

  # enable HDMI output switching with pulseaudio
  hardware.pulseaudio.configFile = pkgs.writeText "pulse-default-pa" ''
    ${builtins.readFile "${config.hardware.pulseaudio.package}/etc/pulse/default.pa"}
    load-module module-alsa-sink device=hw:0,3 sink_properties=device.description="HDMIOutput" sink_name="HDMI"
  '';

}
