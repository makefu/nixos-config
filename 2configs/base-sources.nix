{ config, lib, pkgs, ... }:

{
  krebs.build.source = {
    git.nixpkgs = {
      url = https://github.com/NixOS/nixpkgs;
      #url = https://github.com/makefu/nixpkgs;
      rev = "68bd8e4a9dc247726ae89cc8739574261718e328";
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
