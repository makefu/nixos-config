{ config, lib, pkgs, ... }:
# TODO test `alsactl init` after suspend to reinit mic
{
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    alsaUtils
    pulseaudio
    ponymix
  ];

  services.pipewire = {
    enable = true;
    systemWide = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
