{ config, pkgs, ... }:

{
  krebs.fetchWallpaper = {
    enable = true;
    display = ":0.0";
    unitConfig.ConditionPathExists = "!/var/run/ppp0.pid";
    timerConfig = {
      OnCalendar = "*:0/30";
    };
    url = "http://prism.r/realwallpaper-sat-krebs.png";
  };

}

