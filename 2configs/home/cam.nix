{
  # the pseyecam in the diorama

  services.mjpg-streamer = {
      enable = true;
      inputPlugin = "input_uvc.so -d /dev/web_cam -r 640x480 -f 10 -y";
      outputPlugin = "output_http.so -w @www@ -n -p 18088";
  };
}
