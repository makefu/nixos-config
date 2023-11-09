{
  # the pseyecam in the diorama
  services.udev.extraRules = ''
    KERNEL=="video*",ATTRS{vendor}=="0x1415", ATTRS{device}=="0x2000", GROUP="video", SYMLINK+="diorama_cam"
  '';
  services.mjpg-streamer = {
      enable = true;
      inputPlugin = "input_uvc.so -d /dev/diorama_cam -r 640x480 -y -f 30 -q 50 -n";
      outputPlugin = "output_http.so -w @www@ -n -p 18088";
  };
}