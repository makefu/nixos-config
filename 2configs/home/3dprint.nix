{ pkgs, ... }:
let
  #dev = "/dev/web_cam";
  dev = "/dev/web_cam";
in
{
  services.mjpg-streamer = {
    enable = true;
    # new camera
    #inputPlugin = "input_uvc.so -d ${dev} -r 1280x960";
    # ps eye came
    inputPlugin = "input_uvc.so -y -d ${dev} -r 640x480";
  };
  users.users.octoprint.extraGroups = [ "video" ];

  # allow octoprint to access /dev/vchiq
  # also ensure that the webcam always comes up under the same name
  services.udev.extraRules = ''
    SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"
    KERNEL=="video*",ATTRS{vendor}=="0x046d", ATTRS{device}=="0x0825", GROUP="video", SYMLINK+="web_cam"
    KERNEL=="video*",ATTRS{vendor}=="0x1415", ATTRS{device}=="0x2000", GROUP="video", SYMLINK+="web_cam"
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
        version = "3.6.2";
        src = pkgs.fetchFromGitHub {
          owner = "cmroche";
          repo = pname;
          rev = version;
          hash = "sha256-oo9OBmHoJFNGK7u9cVouMuBuUcUxRUrY0ppRq0OS1ro=";
        };
      })
    ];
    extraConfig.plugins.mqtt.broker = {
      url = "omo.lan";
      # TODO TODO TODO
      username = "hass";
      password = "lksue43jrf";
      # TODO TODO TODO
    };
  };
}
