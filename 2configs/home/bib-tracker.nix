{ config, pkgs, inputs, ... }:
let
  port = 8099;
in {
  imports = [ inputs.bib-tracker.nixosModules.default ];

  sops.secrets."bib-tracker-stuttgart-password" = {};
  sops.secrets."bib-tracker-remseck-password" = {};
  sops.secrets."bib-tracker-bgg-token" = {};

  services.bib-tracker = {
    enable = true;
    openFirewall = true;
    package = pkgs.bib-tracker;
    inherit port;
    accounts = {
      stuttgart = {
        libraryType = "stuttgart";
        username = "5980610";
        passwordFile = config.sops.secrets."bib-tracker-stuttgart-password".path;
      };
      remseck = {
        libraryType = "remseck";
        username = "103167";
        passwordFile = config.sops.secrets."bib-tracker-remseck-password".path;
      };
    };
    metadata = {
      enable = true;
      providers = [ "openlibrary" "dnb" "wikidata" "bgg" ];
      apiKeyFiles.bgg = config.sops.secrets."bib-tracker-bgg-token".path;
    };
  };

  # The UI has no authentication, so it stays reachable on the LAN only.
  services.nginx.virtualHosts."bib-tracker" = {
    serverAliases = [ "bib.lan" ];
    locations."/".proxyPass = "http://localhost:${toString port}";
  };
}
