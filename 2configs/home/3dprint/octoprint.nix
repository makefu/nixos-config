{
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
  users.users.octoprint.extraGroups = [ "video" ];
  systemd.services.octoprint = {
    path = [ pkgs.libraspberrypi ];
  };
}
