{ config, ... }:
# back up all state
let
  sshkey = config.sops.secrets."${config.clan.core.machineName}-borg.priv".path;
  phrase = config.sops.secrets."${config.clan.core.machineName}-borg.pw".path;
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
