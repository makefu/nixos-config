{ pkgs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.0.2u" # required for studio-link
  ];
  users.users.makefu.packages = with pkgs; [
    obs-studio
    studio-link
    audacity
    #darkice
    # owncloudclient
    (pkgs.writeScriptBin "prepare-pulseaudio" ''
      pactl load-module module-null-sink sink_name=stream sink_properties=device.description="Streaming"
      pactl load-module module-loopback source=alsa_output.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.analog-stereo.monitor sink=stream
      pactl load-module module-loopback source=alsa_input.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.analog-stereo sink=stream
      darkice -c ./lol.conf
    '')
  ];
}
