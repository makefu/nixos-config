{ config, pkgs, ... }:

let
  # check if laptop runs on umts
  weaksauce-internet = with pkgs;writeScript "weaksauce-internet" ''
    #! /bin/sh
    if  ${iproute}/bin/ip addr show dev ppp0 2>/dev/null \
      | ${gnugrep}/bin/grep -q inet;then
      exit 1
    fi
  '';

in {
  krebs.fetchWallpaper = {
    enable = true;
    display = ":0";
    predicate = weaksauce-internet;
    timerConfig = {
      OnCalendar = "*:0/30";
    };
    url = "http://echelon/wallpaper.png";
  };
}

