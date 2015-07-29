{ config, lib, pkgs, ... }:
# TODO: remove tv lib :)
with import ../../tv/4lib { inherit lib pkgs; };
let

  repos = priv-repos // krebs-repos ;
  rules = concatMap krebs-rules (attrValues krebs-repos) ++ concatMap priv-rules (attrValues priv-repos);

  krebs-repos = mapAttrs make-krebs-repo {
    stockholm = {
      desc = "take all the computers hostage, they'll love you!";
    };
  };

  priv-repos = mapAttrs make-priv-repo {
    autosync = { };
  };


  # TODO move users to separate module
  make-priv-repo = name: { desc ? null, ... }: {
    inherit name desc;
    public = false;
  };

  make-krebs-repo = with git; name: { desc ? null, ... }: {
    inherit name desc;
    public = true;
    hooks = {
      post-receive = git.irc-announce {
        nick = config.networking.hostName;
        channel = "#retiolum";
        server = "cd.retiolum";
      };
    };
  };

  set-owners = with git; repo: user:
      singleton {
        inherit user;
        repo = [ repo ];
        perm = push "refs/*" [ non-fast-forward create delete merge ];
      };

  set-ro-access = with git; repo: user:
      optional repo.public {
        inherit user;
        repo = [ repo ];
        perm = fetch;
      };

  # TODO: get the list of all krebsministers
  krebsminister = with config.krebs.users; [ lass tv uriel ];

  priv-rules = with config.krebs.users; repo:
    set-owners repo [ makefu ];

  krebs-rules = with config.krebs.users; repo:
    set-owners repo [ makefu ] ++ set-ro-access repo krebsminister ;

in {
  imports = [ ../../3modules/krebs/git.nix ];
  krebs.git = {
    enable = true;
    root-title = "public repositories ";
    root-desc = "keep on krebsing";
    inherit repos rules;
  };
}
