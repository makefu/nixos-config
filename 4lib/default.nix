{ config, lib, ... }:

with lib;
let
  addDefaultTime = bku-entry: recursiveUpdate {
    snapshots = {
      daily    = { format = "%Y-%m-%d"; retain =  7; };
      weekly   = { format = "%YW%W";    retain =  4; };
      monthly  = { format = "%Y-%m";    retain = 12; };
      yearly   = { format = "%Y";                    };
    };
    startAt = "5:23";
  } bku-entry;

  backup-host = config.krebs.hosts.omo;
  backup-path = "/media/backup";
in {
  bku = {
    inherit addDefaultTime;
    simplePath = addDefaultTime (path: {
      method = "pull";
      src = { host = config.krebs.build.host; inherit path; };
      dst = {
        host = backup-host;
        path = backup-path ++ config.krebs.build.host.name
                           ++ builtins.replaceStrings ["/"] ["-"] path;
      };
    });
  };
}
