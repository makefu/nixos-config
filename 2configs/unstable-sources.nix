{ config, lib, pkgs, ... }:

{
  system.stateVersion = "15.09";
  krebs.build.source = {
    git.nixpkgs = {
      url = https://github.com/makefu/nixpkgs;
      rev = "15b5bbfbd1c8a55e7d9e05dd9058dc102fac04fe"; # cherry-picked collectd
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
