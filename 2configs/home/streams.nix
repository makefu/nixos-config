{ pkgs, config, lib, ...}:
let
  port = "2348";
in
{
  # sonos does not support streams without ".mp3" at the end
  services.nginx.virtualHosts."streams.lan" = {
    locations."/teddy.mp3".return ="307 https://irmedia.streamabc.net/irm-rtliveplus-mp3-192-4919509";
    locations."/teddykinder.mp3".return ="307 https://irmedia.streamabc.net/irm-rtkinderlieder-mp3-192-1697446";
    locations."/teddy1.mp3".return ="307 https://irmedia.streamabc.net/irm-rtpersoplus01-mp3-192-4976733";
    locations."/teddyinfo.mp3".return ="307 https://irmedia.streamabc.net/irm-rtinfospass-mp3-192-7462684";
  };

}
