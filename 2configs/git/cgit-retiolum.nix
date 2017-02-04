{ config, lib, pkgs, ... }:
# TODO: remove tv lib :)
with import <stockholm/lib>;
let

  repos = priv-repos // krebs-repos // connector-repos ;
  rules = concatMap krebs-rules (attrValues krebs-repos)
    ++ concatMap priv-rules (attrValues priv-repos)
    ++ concatMap connector-rules (attrValues connector-repos);

  krebs-repos = mapAttrs make-krebs-repo {
    stockholm = {
      cgit.desc = "Make all the systems into 1systems!";
    };
    tinc_graphs = {
      cgit.desc = "Tinc Advanced Graph Generation";
    };
    stockholm-init = {
      cgit.desc = "Build new Stockholm hosts";
    };
    cac-api = { };
    init-stockholm = {
      cgit.desc = "Init stuff for stockholm";
    };
  };

  priv-repos = mapAttrs make-priv-repo {
    autosync = { };
    pass = { };
  };

  connector-repos = mapAttrs make-priv-repo {
    connector = { };
    minikrebs = { };
    mattermost = {
      cgit.desc = "Mattermost Docker files";
    };
  };


  # TODO move users to separate module
  make-priv-repo = name: { ... }: {
    inherit name;
    public = false;
  };

  make-krebs-repo = with git; name: { cgit ? {}, ... }: {
    inherit cgit name;
    public = true;
    hooks = {
      post-receive = pkgs.git-hooks.irc-announce {
        nick = config.networking.hostName;
        verbose = config.krebs.build.host.name == "gum";
        channel = "#retiolum";
        # TODO remove the hardcoded hostname
        server = "ni.r";
      };
    };
  };



  # TODO: get the list of all krebsministers
  krebsminister = with config.krebs.users; [ lass tv ];
  all-makefu = with config.krebs.users; [ makefu makefu-omo makefu-tsp makefu-vbob makefu-tempx ];
  all-exco = with config.krebs.users; [ exco ];

  priv-rules = repo: set-owners repo all-makefu;

  connector-rules = repo: set-owners repo all-makefu ++ set-owners repo all-exco;

  krebs-rules = repo:
    set-owners repo all-makefu ++ set-ro-access repo krebsminister;

  set-ro-access = with git; repo: user:
      optional repo.public {
        inherit user;
        repo = [ repo ];
        perm = fetch;
      };

  set-owners = with git;repo: user:
      singleton {
        inherit user;
        repo = [ repo ];
        perm = push "refs/*" [ non-fast-forward create delete merge ];
      };

in {
  krebs.git = {
    enable = true;
    cgit = {
      settings = {
        root-title = "public repositories";
        root-desc = "keep on krebsing";
      };
    };
    inherit repos rules;
  };
}
