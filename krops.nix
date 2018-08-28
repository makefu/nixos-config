{ config ? config, name }: let
  krops = builtins.fetchGit {
    url = https://cgit.krebsco.de/krops/;
    rev = "4e466eaf05861b47365c5ef46a31a188b70f3615";
  };
  nixpkgs-src = lib.importJSON ./nixpkgs.json;
  lib = import "${krops}/lib";

  # TODO document why pkgs should be used like this
  pkgs = import "${krops}/pkgs" {};
  hostSource = {
    secure = false;
    full = false;
    torrent = false;
    hw = false;
    musnix = false;
    python = false;
    unstable = false; #unstable channel checked out
    mic92 = false;
    nms = false;
    clever_kexec = false;
  } // import (./. + "/1systems/${name}/source.nix");
  source = { test }: lib.evalSource [
    {
      # nixos-18.03 @ 2018-08-06
      # + do_sqlite3 ruby:   55a952be5b5
      # + exfat-nofuse bump: ee6a5296a35
      # + uhub/sqlite: 5dd7610401747
      nixpkgs.git = {
        ref = nixpkgs-src.rev;
        url = nixpkgs-src.url;
      };
      nixos-config.symlink = "stockholm/makefu/1systems/${name}/config.nix";

      stockholm.file = toString <stockholm>;
      secrets = if test then {
        file = toString (./. + "/0tests/data/secrets");
      } else {
        pass = {
          dir = "${lib.getEnv "HOME"}/.secrets-pass";
          inherit name;
        };
      };
    }
    (lib.mkIf (hostSource.torrent) {
      torrent-secrets = if test then {
        file =  ./. + "/makefu/0tests/data/secrets";
      } else {
        pass = {
          dir = "${lib.getEnv "HOME"}/.secrets-pass";
          name = "torrent";
        };
      };
    })
    (lib.mkIf ( hostSource.musnix ) {
      musnix.git = {
        url = https://github.com/musnix/musnix.git;
        ref = "master"; # follow the musnix channel, lets see how this works out
      };
    })
    (lib.mkIf ( hostSource.hw ) {
      nixos-hardware.git = {
        url = https://github.com/nixos/nixos-hardware.git;
        ref = "30fdd53";
      };
    })
  ];

in {
  # usage: $(nix-build --no-out-link --argstr name HOSTNAME -A deploy)
  deploy = pkgs.krops.writeDeploy "${name}-deploy" {
    source = source { test = false; };
    target = "root@${name}/var/src";
  };

  # usage: $(nix-build --no-out-link --argstr name HOSTNAME -A test)
  test = pkgs.krops.writeTest "${name}-test" {
    source = source { test = true; };
    target = "${lib.getEnv "HOME"}/tmp/${name}-krops-test-src";
  };

  ci = map (host:
    pkgs.krops.writeTest "${host.name}-test" {
      source = source { test = true; };
      target = "${lib.getEnv "TMPDIR"}/makefu/${host.name}";
    }
  ) (lib.filter (host: lib.getAttr "ci" host && host.owner == "makefu") (lib.attrValues config.krebs.hosts));
}
