with import <stockholm/lib>;
host@{ name,
  override ? {},
  secure ? false,
  full ? false,
  torrent ? false,
  musnix ? false
}:
let
  builder = if getEnv "dummy_secrets" == "true"
              then "buildbot"
              else "makefu";
  _file = <stockholm> + "/makefu/1systems/${name}/source.nix";
  ref = "59e7765"; # unstable @ 2017-09-04
                   # + graceful requests2 (a772c3a)
                   # + mitmproxy fix      (eee2d17)
                   # + tpm-tools fix      (5cb9987)
                   # + dnscrypt-wrapper   (25703c3)
                   # + lass wvstream fix  (76f4910,37cc2bc,0d48837)
                   # + ruby stuff (2f0b17e4be9,55a952be5b5)
                   # + proot aarch64 fix (05d2603173d)

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
    (mkIf ( torrent ) {
      torrent-secrets.file = getAttr builder {
        buildbot = toString <stockholm/makefu/6tests/data/secrets>;
        makefu = "/home/makefu/secrets/torrent" ;
      };
    })
    override
  ]
