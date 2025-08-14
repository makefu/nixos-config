{config, ... }:
let
    port = 8641;
in
{
    sops.secrets.restic-server-htpasswd = {};
    services.restic.server = {
        enable = true;
        listenAddress = toString port;
        dataDir = "/media/cryptX/backup/restic";
        htpasswd-file = config.sops.secrets.restic-server-htpasswd;
    };
    networking.firewall.allowedTCPPorts = [ port ];
}
