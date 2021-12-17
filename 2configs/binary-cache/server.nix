{ config, lib, pkgs, ...}:

{
  # generate private key with:
  # nix-store --generate-binary-cache-key gum nix-serve.key nix-serve.pub
  services.nix-serve = {
    enable = true;
    port = 5001;
    secretKeyFile = toString <secrets> + "/nix-serve.key";
  };

  services.nginx = {
    enable = true;
    virtualHosts."cache.euer.krebsco.de" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ # "cache.gum.r"
                        "cache.gum.krebsco.de"
                      ];
      locations."/".proxyPass= "http://localhost:${toString config.services.nix-serve.port}";
    };
  };
}

