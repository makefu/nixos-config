{ config, pkgs, ... }:
let
  system = builtins.currentSystem; #we can also build for other platforms
  iso = (import <nixpkgs/nixos/lib/eval-config.nix>
      { inherit system;
        modules = [ ../../1systems/iso/config.nix ]; }

    );
  image = iso.config.system.build.isoImage;
  name = iso.config.isoImage.isoName;

  drivedroid-cfg = builtins.toJSON [{
    id = "stockholm";
    name = "stockholm";
    tags = [ "hybrid" ];
    url = http://krebsco.de;
    releases = [
      { version = iso.config.system.nixos.label;
        url = "/stockholm.iso";
        arch = system; }
    ];
    # size = TODO;
  }];
  web = pkgs.linkFarm "web" [{
    name = "drivedroid.json";
    path = pkgs.writeText "drivedroid.json" drivedroid-cfg; }
  { name = "stockholm.iso";
    path = "${image}/iso/${name}"; }
  ];
in
{
  services.nginx = {
    virtualHosts = {
      "iso.euer.krebsco.de" = {
        enableACME = true;
        forceSSL = true;
        root = web;
        locations."/".index = "drivedroid.json";
      };
    };
  };
}
