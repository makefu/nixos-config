{ config ? config, name, target ? name , buildTarget ? target }: let
  krops = ../submodules/krops;
  nixpkgs-src = lib.importJSON ../krebs/nixpkgs.json;

  lib = import "${krops}/lib";
  pkgs = import "${krops}/pkgs" {};

  host-src = {
    secure = false;
    torrent = false;
    hw = false;
    musnix = false;
    python = false;
    unstable = false; #unstable channel checked out
    mic92 = false;
    nms = false;
    arm6 = false;
    clever_kexec = false;
    home-manager = false;
    nix-ld = false;
  } // import (./. + "/1systems/${name}/source.nix");
  source = { test }: lib.evalSource [
    {
      nixpkgs = if host-src.arm6 then {
        # TODO: we want to track the unstable channel
        symlink = "/nix/var/nix/profiles/per-user/root/channels/nixos/";
      } else {
        derivation = ''
          with import (builtins.fetchTarball {
            url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-src.rev}.tar.gz";
            sha256 = "${nixpkgs-src.sha256}";
          }) {};
          pkgs.fetchFromGitHub {
            owner = "nixos";
            repo = "nixpkgs";
            rev = "${nixpkgs-src.rev}";
            sha256 = "${nixpkgs-src.sha256}";
          }
        '';
      };
      nixos-config.symlink = "stockholm/makefu/1systems/${name}/config.nix";

      stockholm.file = toString ./..;
      secrets = if test then {
        file = toString ./0tests/data/secrets;
      } else {
        pass = {
          dir = "${lib.getEnv "HOME"}/.secrets-pass";
          inherit name;
        };
      };
    }
    (lib.mkIf (host-src.unstable) {
      nixpkgs-unstable.git = {
          url = "https://github.com/nixos/nixpkgs";
          ref = (lib.importJSON ../krebs/nixpkgs-unstable.json).rev;
        };
    })
    (lib.mkIf (host-src.torrent) {
      torrent-secrets = if test then {
        file =  toString ./0tests/data/secrets;
      } else {
        pass = {
          dir = "${lib.getEnv "HOME"}/.secrets-pass";
          name = "torrent";
        };
      };
    })
    (lib.mkIf ( host-src.musnix ) {
      musnix.git = {
        url = https://github.com/musnix/musnix.git;
        ref = "master"; # follow the musnix channel, lets see how this works out
      };
    })
    (lib.mkIf ( host-src.hw ) {
      nixos-hardware.git = {
        url = https://github.com/nixos/nixos-hardware.git;
        ref = "9d87bc030a0bf3f00e953dbf095a7d8e852dab6b";
      };
    })

    (lib.mkIf ( host-src.nix-ld ) {
      nix-ld.git = {
        url = https://github.com/Mic92/nix-ld.git;
        ref = "7d251c0c5adf6b9b003499243be257d0f130b3d6";
      };
    })
    (lib.mkIf ( host-src.home-manager ) {
      home-manager.git = {
        url = https://github.com/rycee/home-manager;
        ref = "054d9e3187ca00479e8036dc0e92900a384f30fd";
      };
    })
  ];

in {
  # usage: $(nix-build --no-out-link --argstr name HOSTNAME -A deploy)
  deploy = pkgs.krops.writeDeploy "${name}-deploy" {
    source = source { test = false; };
    target = "root@${target}/var/src";
    buildTarget = if target == buildTarget then "root@${target}/var/src" else "root@${buildTarget}/tmp/";
  };

  # usage: $(nix-build --no-out-link --argstr name HOSTNAME --argstr target PATH -A test)
  test = { target ? target }: pkgs.krops.writeTest "${name}-test" {
    force = true;
    inherit target;
    source = source { test = true; };
  };
}
