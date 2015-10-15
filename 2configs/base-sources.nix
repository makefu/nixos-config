{ config, lib, pkgs, ... }:

{
  krebs.build.source = {
    git.nixpkgs = {
      url = https://github.com/NixOS/nixpkgs;
      #url = https://github.com/makefu/nixpkgs;
      rev = "dc18f39bfb2f9d1ba62c7e8ad98544bb15cb26b2"; # nixos-15.09
    };

    dir.secrets = {
      host = config.krebs.hosts.pornocauster;
      path = "/home/makefu/secrets/${config.krebs.build.host.name}/";
    };
    dir.stockholm = {
      host = config.krebs.hosts.pornocauster;
      path = toString ../.. ;
    };
  };
}
