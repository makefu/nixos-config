{ config, pkgs, ... }:
{
  services.nginx.virtualHosts."wikisearch.krebsco.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:6080";
  };
  services.hound = {
    enable = true;
    listen = "127.0.0.1:6080";
    # package = pkgs.hound.overrideDerivation(oldAttrs: {
    #   patches = [ ./keep-repo.patch ];
    # });
    config = ''{
        "max-concurrent-indexers" : 2,
        "dbpath" : "${config.services.hound.home}/data",
        "repos" : {
          "nixos-users-wiki": {
            "url" : "https://github.com/nixos-users/wiki.wiki.git",
            "url-pattern" : {
              "base-url" : "{url}/{path}"
            }
          }
        }
      }'';
  };

}
