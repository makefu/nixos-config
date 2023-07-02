{ pkgs, lib, ... }:

with lib;
let
  name = "bgt_cyberwar_hidden_service";
  srvdir = "/var/lib/tor/onion/";
in
  {
  sops.secrets."bgt_cyberwar_hidden_service/private_key" = {
    path = "${srvdir}/${name}/private_key";
    owner = "tor";
    restartUnits = [ "tor.service" ];
  };
  sops.secrets."bgt_cyberwar_hidden_service/hostname" = {
    path = "${srvdir}/${name}/hostname";
    owner = "tor";
    restartUnits = [ "tor.service" ];
  };
  services.nginx.virtualHosts."cyberwar62fmmhe4.onion".locations."/" = {
    proxyPass = "https://blog.binaergewitter.de";
    extraConfig = ''
        proxy_set_header  Host blog.binaergewitter.de;
        proxy_ssl_server_name on;
    '';
  };
  services.tor = {
    enable = true;
    hiddenServices."${name}".map = [
     { port = 80; }
     # { port = 443; toHost = "blog.binaergewitter.de"; }
    ];
  };
}
