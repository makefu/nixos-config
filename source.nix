with import <stockholm/lib>;
host@{ name,
  override ? {}
, secure ? false
, full ? false
, torrent ? false
, hw ? false
, musnix ? false
, python ? false
, unstable ? false #unstable channel checked out
, mic92 ? false
, nms ? false
, clever_kexec ?false
}:
let
  builder = if getEnv "dummy_secrets" == "true"
              then "buildbot"
              else "makefu";
  _file = <stockholm> + "/makefu/1systems/${name}/source.nix";
  pkgs = import <nixpkgs> {
    overlays = map import [
      <stockholm/krebs/5pkgs>
    ];
  };
  # TODO: automate updating of this ref + cherry-picks
  ref = "a09afbfb8a4"; # nixos-18.03 @ 2018-04-04
                       # + do_sqlite3 ruby: 55a952be5b5

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

      secrets = getAttr builder {
        buildbot.file = toString <stockholm/makefu/0tests/data/secrets>;
        makefu.pass = {
          inherit name;
          dir = "${getEnv "HOME"}/.secrets-pass";
        };
      };


      stockholm.file = toString <stockholm>;
      stockholm-version.pipe = "${pkgs.stockholm}/bin/get-version";
    }
    (mkIf ( musnix ) {
      musnix.git = {
        url = https://github.com/musnix/musnix.git;
        ref = "master"; # follow the musnix channel, lets see how this works out
      };
    })

    (mkIf ( hw ) {
      nixos-hardware.git = {
        url = https://github.com/nixos/nixos-hardware.git;
        ref = "30fdd53";
      };
    })

    (mkIf ( python ) {
      python.git = {
        url = https://github.com/garbas/nixpkgs-python;
        ref = "cac319b7";
      };
    })

    (mkIf ( torrent ) {
      torrent-secrets = getAttr builder {
        buildbot.file = toString <stockholm/makefu/0tests/data/secrets>;
        makefu.pass = {
          name = "torrent";
          dir = "${getEnv "HOME"}/.secrets-pass";
        };
      };
    })

    (mkIf ( unstable ) {
      nixpkgs-unstable.git = {
        url = https://github.com/nixos/nixpkgs-channels;
        ref = "nixos-unstable";
      };
    })

    (mkIf ( mic92 ) {
      mic92.git = {
        url = https://github.com/Mic92/dotfiles/;
        ref = "48a1f49";
      };
    })

    (mkIf ( nms ) {
      nms.git = {
        url = https://github.com/r-raymond/nixos-mailserver;
        ref = "v2.1.2";
      };
    })

    (mkIf ( clever_kexec ) {
      clever_kexec.git = {
        url = https://github.com/cleverca22/nix-tests;
        ref = "5a670de7f2decfaafc95c34ffeb0f1896662f3d7";
      };
    })

    override
  ]
