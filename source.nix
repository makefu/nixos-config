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
  ref = "1e478271"; # unstable @ 2017-07-31 + graceful requests2 (a772c3aa) + libpurple bitlbee ( ce6fe1a, 65e38b7 )

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
          # TODO use http, once it is implemented
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