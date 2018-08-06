{ config, lib, pkgs, ...}:

{
  # generate private key with:
  # nix-store --generate-binary-cache-key gum nix-serve.key nix-serve.pub
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.krebs.secret.files.nix-serve-key.path;
  };

  systemd.services.nix-serve = {
    requires = ["secret.service"];
    after = ["secret.service"];
  };
  krebs.secret.files.nix-serve-key = {
    path = "/run/secret/nix-serve.key";
    owner.name = "nix-serve";
    source-path = toString <secrets> + "/nix-serve.key";
  };
  services.nginx = {
    enable = true;
    virtualHosts.nix-serve = {
      serverAliases = [ "cache.gum.r"
                        "cache.euer.krebsco.de"
                        "cache.gum.krebsco.de"
                      ];
      locations."/".proxyPass= "http://localhost:${toString config.services.nix-serve.port}";
    };
  };
}

