let
  dev = "/dev/web_cam";
in
{

  services.mjpg-streamer = {
    enable = true;
    # new camera
    #inputPlugin = "input_uvc.so -d ${dev} -r 1280x960";
    inputPlugin = "input_uvc.so -y -d ${dev} -r 640x480 -f 5"; # ps eyecam

    # outputPlugin = "output_http.so -w @www@ -n -p 18088";
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"
    SUBSYSTEM=="video4linux", ATTRS{idVendor}=="1415", ATTRS{idProduct}=="2000", SYMLINK+="web_cam"
  '';
  users.users.mjpg-streamer.extraGroups = [ "video" ];
}
