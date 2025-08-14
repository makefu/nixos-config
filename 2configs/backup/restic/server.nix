{config, ... }:
let
    port = 8641;
    dataDir = "/media/cryptX/backup/restic";
in
    {
    sops.secrets.restic-server-htpasswd.owner = "restic";
    services.restic.server = {
        enable = true;
        listenAddress = toString port;
        inherit dataDir;
        htpasswd-file = config.sops.secrets.restic-server-htpasswd.path;
    };
    networking.firewall.allowedTCPPorts = [ port ];
    systemd.tmpfiles.rules = [
        "d ${dataDir} 0770 restic restic - -"
    ];
}
