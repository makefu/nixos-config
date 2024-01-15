{
  # the pseyecam in the diorama
  services.udev.extraRules = ''
    SUBSYSTEM=="video4linux", ATTRS{idVendor}=="1415", ATTRS{idProduct}=="2000", SYMLINK+="diorama_cam"
  '';
  services.mjpg-streamer = {
      enable = true;
      inputPlugin = "input_uvc.so -d /dev/diorama_cam -r 640x480 -y -f 30 -q 50 -n";
      outputPlugin = "output_http.so -w @www@ -n -p 18088";
  };
}
