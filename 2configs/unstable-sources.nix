{ config, lib, pkgs, ... }:

{
  krebs.build.source = {
    git.nixpkgs = {
      url = https://github.com/makefu/nixpkgs;
      rev = "984d33884d63d404ff2da76920b8bc8b15471552";
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
