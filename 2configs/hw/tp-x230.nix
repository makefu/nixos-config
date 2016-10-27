{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{

  imports = [ ./tp-x2x0.nix ];
  boot = {
    # tp-smapi is not supported bt x230 anymore
    kernelModules = [
      "kvm-intel"
      "thinkpad_ec"
   #   "acpi_call"
   #   "thinkpad_acpi"
   #   "tpm-rng"
    ];
    extraModulePackages = [
    #  config.boot.kernelPackages.acpi_call
    ];
  };
  services.acpid.enable = true;
  hardware.opengl.extraPackages =  [ pkgs.vaapiIntel pkgs.vaapiVdpau ];
  services.xserver = {
    videoDriver = "intel";
    deviceSection = ''
      Option "AccelMethod" "sna"
    '';
  };
  # no entropy source working
  # security.rngd.enable = true;

  services.xserver.displayManager.sessionCommands =''
    xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
    xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
    # xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 8 200
  '';

  # enable HDMI output switching with pulseaudio
  hardware.pulseaudio.configFile = pkgs.writeText "pulse-default-pa" ''
    ${builtins.readFile "${config.hardware.pulseaudio.package.out}/etc/pulse/default.pa"}
    load-module module-alsa-sink device=hw:0,3 sink_properties=device.description="HDMIOutput" sink_name="HDMI"
  '';

}
