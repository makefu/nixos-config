{ pkgs, ... }:
let
  dev = "/dev/web_cam";
in
{
  services.mjpg-streamer = {
    enable = true;
    # new camera
    #inputPlugin = "input_uvc.so -d ${dev} -r 1280x960";
    # ps eye came
    inputPlugin = "input_uvc.so -y -d ${dev} -r 640x480 -f 5";

    # outputPlugin = "output_http.so -w @www@ -n -p 18088";
  };
  users.users.octoprint.extraGroups = [ "video" ];
  users.users.mjpg-streamer.extraGroups = [ "video" ];

  # allow octoprint to access /dev/vchiq
  # also ensure that the webcam always comes up under the same name
  services.udev.extraRules = ''
    SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"
    SUBSYSTEM=="video4linux", ATTRS{idVendor}=="1415", ATTRS{idProduct}=="2000", SYMLINK+="web_cam"
  '';

  systemd.services.octoprint = {
    path = [ pkgs.libraspberrypi ];
  };
  services.octoprint = {
    enable = true;
    plugins = plugins: with plugins;[
      costestimation
      displayprogress
      mqtt
      stlviewer
      themeify
      # octolapse
      (buildPlugin rec {
        pname = "OctoPrint-HomeAssistant";
        version = "3.7.0";
        src = pkgs.fetchFromGitHub {
          owner = "cmroche";
          repo = pname;
          rev = version;
          hash = "sha256-R6ayI8KHpBSR2Cnp6B2mKdJGHaxTENkOKvbvILLte2E=";
        };
      })
    ];
    extraConfig.plugins.mqtt.broker = {
      url = "192.168.111.11";
      username = "hass";
      password = "lksue43jrf";
    };
  };
}
