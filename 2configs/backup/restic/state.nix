{ config, lib, ...}:
{
    sops.secrets.restic-auth-environment = {};
    services.restic.backups.state = {
        timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
        };
        checkOpts = [ "--with-cache" ];
        repository = "rest:http://omo.euer:8641/${config.networking.hostName}";
        environmentFile = config.sops.secrets.restic-auth-environment.path;
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
  # run smoothly in background (unit name is restic-backups-<name>)
  systemd.services.restic-backups-state.serviceConfig = {
    Nice = lib.mkForce 15;
    CPUWeight = lib.mkForce 10;
    IOWeight = lib.mkForce 10;
    IOSchedulingClass = lib.mkForce "idle";
    IOSchedulingPriority = lib.mkForce 7;
  };
}
