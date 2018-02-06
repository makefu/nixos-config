with import <stockholm/lib>;
host@{ name,
  override ? {},
  secure ? false,
  full ? false,
  torrent ? false,
  hw ? false,
  musnix ? false,
  python ? false
}:
let
  builder = if getEnv "dummy_secrets" == "true"
              then "buildbot"
              else "makefu";
  _file = <stockholm> + "/makefu/1systems/${name}/source.nix";
  ref = "cd36b3d"; # nixos-17.09 @ 2018-02-06
                   # + do_sqlite3 ruby: 55a952be5b5
                   # + signal: 0f19beef3

in
  evalSource (toString _file) [
    {
      nixos-config.symlink = "stockholm/makefu/1systems/${name}/config.nix";
      # always perform a full populate when buildbot
      nixpkgs = if full || (builder == "buildbot" ) then {
          git = {
            url = https://github.com/makefu/nixpkgs;
            inherit ref;
          };
        } else {
          # right now it is simply extracted revision folder

          ## prepare so we do not have to wait for rsync:
          ## cd /var/src; curl https://github.com/nixos/nixpkgs/tarball/125ffff  -L | tar zx  && mv NixOS-nixpkgs-125ffff nixpkgs
          file = "/home/makefu/store/${ref}";
        };

      secrets.file = getAttr builder {
        buildbot = toString <stockholm/makefu/6tests/data/secrets>;
        makefu = "/home/makefu/secrets/${name}";
      };

      stockholm.file = toString <stockholm>;
    }
    (mkIf ( musnix ) {
      musnix.git = {
        url = https://github.com/musnix/musnix.git;
        ref = "d8b989f";
      };
    })

    (mkIf ( hw ) {
      nixos-hardware.git = {
        url = https://github.com/nixos/nixos-hardware.git;
        ref = "8a05dc9";
      };
    })

    (mkIf ( python ) {
      python.git = {
        url = https://github.com/garbas/nixpkgs-python;
        ref = "cac319b";
      };
    })
    (mkIf ( torrent ) {
      torrent-secrets.file = getAttr builder {
        buildbot = toString <stockholm/makefu/6tests/data/secrets>;
        makefu = "/home/makefu/secrets/torrent" ;
      };
    })
    override
  ]
