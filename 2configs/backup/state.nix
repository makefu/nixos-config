{ config, ... }:
# back up all state
let
  sec = toString <secrets>;
  sshkey = sec + "/borg.priv";
  phrase = sec + "/borg.pw";
in
{
  services.borgbackup.jobs.state = {
    repo = "borg-${config.krebs.build.host.name}@backup.makefu.r:.";
    paths = config.state;
    encryption = {
      mode = "repokey";
      passCommand = "cat ${phrase}";
    };
    environment.BORG_RSH = "ssh -i ${sshkey}";
    prune.keep =
    { daily = 7;
      weekly = 4;
      monthly = -1; # Keep at least one archive for each month
    };
    compression = "auto,lzma";
    startAt = "daily";
  };
}
