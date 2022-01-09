{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
let
  domain = "over.voltage.nz";
in {

  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."mediengewitter.de" = {
      enableACME = true;
      forceSSL = true;
      locations."/".return = "301 http://${domain}\$request_uri";
      #locations."/" = {
      #  proxyPass = "http://over.voltage.nz";
      #};
      #locations."/socket.io" = {
      #  proxyPass = "ws://over.voltage.nz";
      #  proxyWebsockets = true;
      #};
    };
  };
}
