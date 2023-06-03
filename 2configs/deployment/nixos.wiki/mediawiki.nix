{ config, pkgs, ... }:

let
  hostAddress = "192.168.48.1";
  localAddress = "192.168.48.3";
in

{
  containers.mediawiki =
  { autoStart = true;
    privateNetwork = true;
    inherit hostAddress localAddress;
    config = { config, pkgs, ... }:
    {
      # NOTE: This disabling and importing is so that the basePath can be altered
      disabledModules = [ "services/web-apps/mediawiki.nix" ];
      imports = [
        ./mediawiki.module.nix
      ];
      time.timeZone = "America/New_York";
      system.stateVersion = "20.09";
      networking.defaultGateway = hostAddress;
      # NOTE: you might want to change this namserver address
      networking.nameservers = [ "8.8.8.8" ];
      networking.firewall.allowedTCPPorts = [ 80 ];
      services.mediawiki = {
        enable = true;
        name = "Example Containerized Wiki";
        # NOTE: here is where the basePath is specified, which requires the imported mediawiki NixOS module
        basePath = "/wiki";
        passwordFile = ./mediawiki.password.txt;
        extraConfig = ''
          $wgRCFeeds['euerkrebsco'] = array(
              'formatter' => 'JSONRCFeedFormatter',
              'uri' => 'udp://euer.krebsco.de:5005',
              'add_interwiki_prefix' => false,
              'omit_bots' => true,
          );
          $wgRCFeeds['euerkrebscoIRC'] = array(
              'formatter' => 'IRCColourfulRCFeedFormatter',
              'uri' => 'udp://euer.krebsco.de:5006',
              'add_interwiki_prefix' => false,
              'omit_bots' => true,
          );
        '';
        virtualHost = {
          hostName = "localhost";
          adminAddr = "root@localhost";
          forceSSL = false;
          addSSL = false;
          onlySSL = false;
          enableACME = false;
        };
      };
    };
  };

  # Put the MediaWiki web page behind an NGINX proxy
  services.nginx = {
    enable = true;
    virtualHosts.localhost.locations."/wiki" = {
      # NOTE: the slash at the end of the URI is important.  It causes the location base path to be removed when passed onto the proxy
      proxyPass = "http://${localAddress}:80/";
    };
  };

}
