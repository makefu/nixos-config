{ config, lib, ... }:
with import <stockholm/lib>;
let
  # preparation:
  # mkdir -p defaultBackupDir/host.name/src
  # as root on omo:
  #   ssh-copy-id root@src
  startAt = "0,6,12,18:00";
  defaultBackupServer = config.krebs.hosts.omo;
  defaultBackupDir = "/home/backup";
  defaultPull = host: src: {
    method = "pull";
    src = {
      inherit host;
      path = src;
    };
    dst = {
      host = defaultBackupServer;
      path = "${defaultBackupDir}/${host.name}${src}";
    };
    startAt = "0,6,12,18:00";
    snapshots = {
      hourly   = { format = "%Y-%m-%dT%H";    retain =  4; };
      daily    = { format = "%Y-%m-%d";       retain =  7; };
      weekly   = { format = "%YW%W";          retain =  4; };
      monthly  = { format = "%Y-%m";          retain = 12; };
      yearly   = { format = "%Y";                          };
    };
  };
in {
  krebs.backup.plans = {
    # wry-to-omo_root = defaultPull config.krebs.hosts.wry "/";
    gum-to-omo_root = defaultPull config.krebs.hosts.gum "/";
  };
}
