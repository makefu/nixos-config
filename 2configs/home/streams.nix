{ pkgs, config, lib, ...}:
let
  port = "2348";
in
{

  services.nginx.virtualHosts."streams.lan" = {
    locations."/teddy.mp3".return ="307 https://irmedia.streamabc.net/irm-rtliveplus-mp3-192-4919509";
  };

}
