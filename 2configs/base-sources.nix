{ config, lib, pkgs, ... }:

{
  krebs.build.source = {
    git.nixpkgs = {
      #url = https://github.com/NixOS/nixpkgs;
      url = https://github.com/makefu/nixpkgs;
      rev = "78340b042463fd35caa587b0db2e400e5666dbe1"; # nixos-15.09 + cherry-picked iodine
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
