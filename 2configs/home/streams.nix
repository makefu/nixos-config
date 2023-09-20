{ pkgs, config, lib, ...}:
let
  port = "2348";
in
{
  # sonos does not support streams without ".mp3" at the end
  services.nginx.virtualHosts."streams.lan" = {
    locations."/teddy.mp3".return ="307 https://irmedia.streamabc.net/irm-rtliveplus-mp3-192-4919509";
  };

}
