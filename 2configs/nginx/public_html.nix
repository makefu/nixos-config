{ config, lib, ... }:

with config.krebs.lib;

{
  krebs.nginx = {
    enable = true;
    servers.default.locations = [
      (nameValuePair "~ ^/~(.+?)(/.*)?\$" ''
        alias /home/$1/public_html$2;
        autoindex on;
      '')
    ];
  };
}
