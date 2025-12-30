{ config, lib, ...}:
{
    sops.secrets.restic-password = {};
    sops.secrets.restic-omo-repo = {};
    services.restic.backups.state = {
        timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
        };
        checkOpts = [ "--with-cache" ];
        repositoryFile = config.sops.secrets.restic-omo-repo.path;
        pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
            "--keep-yearly 15"
        ];
        paths = config.state;
        passwordFile = config.sops.secrets.restic-password.path;
        initialize = true;
    };
    systemd.tmpfiles.rules = [
        # ensure the run folder exists
        "d /run/restic-backups-state 0770 root root - -"
    ];
    # run smoothly in background
    systemd.services.restic-backup-state.serviceConfig = {
      Nice = lib.mkForce 15;
      IOSchedulingClass = lib.mkForce "idle";
      IOSchedulingPriority = lib.mkForce 7;
    };
}
