{ lib, ... }:
with lib;
let
  port = ident: toString (28000 + ident);
  instances = [ 1 2 3 4 5 6 7 8 9 ];
in {
  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts."warrior.gum.r".locations = let
    # TODO location "/" shows all warrior instances
    proxy = ident: 
    {
      "/warrior${toString ident}/" = {
        proxyPass = "http://localhost:${port ident}/";
          # rewrite   ^/info /warrior${toString ident}/info;
        extraConfig = ''
          sub_filter "http://warrior.gum.r/info" "http://warrior.gum.r/warrior${toString ident}/info";
          sub_filter_once off;
        '';
      };

    };
  in
    foldl' mergeAttrs {} (map proxy instances);
  virtualisation.oci-containers.containers = let
    container = ident:
      { "archiveteam-warrior${toString ident}" = {
        image = "archiveteam/warrior-dockerfile";
        ports = [ "127.0.0.1:${port ident}:8001" ];
        environment = {
          DOWNLOADER = "makefu";
          SELECTED_PROJECT = "auto";
          CONCURRENT_ITEMS = "6";
          WARRIOR_ID = toString ident;
        };
      };
    };
  in
    foldl' mergeAttrs {} (map container instances);
}
