{config, pkgs, ... }:
let
  system = builtins.currentSystem; #we can also build for other platforms
  iso = (import <nixpkgs/nixos/lib/eval-config.nix>
      { inherit system;
        modules = [ ../../1systems/iso/config.nix ]; }

    );
  image = iso.config.system.build.isoImage;
  name = iso.config.isoImage.isoName;
in
{
  services.nginx = {
    virtualHosts = {
      "iso.euer.krebsco.de" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
            root = "${image}/iso";
            index = name;
        };
      };
    };
  };
}
