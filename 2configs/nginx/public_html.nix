{ config, lib, ... }:

with lib;

{
  services.nginx = {
    enable = true;
    virtualHosts.default = {
      default = true;
      locations = {
        "~ ^/~(.+?)(/.*)?\$".extraConfig = ''
          alias /home/$1/public_html$2;
          autoindex on;
        '';
      };
    };
  };
}
