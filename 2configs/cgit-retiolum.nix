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
        # TODO remove the hardcoded hostname
        server = "cd.retiolum";
      };
    };
  };

  set-owners = with git;repo: user:
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

  #all-makefu =  with config.krebs.users; [ makefu ];


  all-makefu = with config.krebs.users; [ makefu makefu-omo ];

  priv-rules = repo: set-owners repo all-makefu;

  krebs-rules = repo:
    set-owners repo all-makefu ++ set-ro-access repo krebsminister;

in {
  imports = [{
    krebs.users.makefu-omo = {
        name = "makefu-omo" ;
        pubkey= with builtins; readFile ../../Zpubkeys/makefu_omo.ssh.pub;
    };
  }];
  krebs.git = {
    enable = true;
    root-title = "public repositories";
    root-desc = "keep on krebsing";
    inherit repos rules;
  };
}
