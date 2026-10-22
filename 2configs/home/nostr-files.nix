# route96: Nostr blob storage (Blossom BUD-01/02/.. + NIP-96) for the nostr
# chat stack. The opencrow bot (2configs/home/llm/agent.nix) uploads charts
# here; the noctalia nostr-chat plugin on x downloads/uploads them.
#
# Ported from Mic92/dotfiles machines/eve/modules/route96.nix (same stack he
# runs publicly as nostr-files.thalheim.io); packaging lives in
# 5pkgs/route96/. Plain HTTP like the strfry relay (2configs/home/nostr-relay.nix):
# *.euer has no public DNS for ACME, wireguard encrypts the transport; *.lan
# is the router wildcard. Test: curl http://nostr-files.euer/.well-known/health
{
  pkgs,
  ...
}:
let
  route96 = pkgs.route96;
  port = 8396;
  dataDir = "/var/lib/route96";

  configFile = pkgs.writeText "route96-config.yaml" ''
    listen: "127.0.0.1:${toString port}"
    database: "mysql://route96@localhost/route96?socket=/run/mysqld/mysqld.sock"
    storage_dir: "${dataDir}/files"
    max_upload_bytes: 104857600
    # URLs embedded in kind-15 tags must resolve on every chat participant:
    # euer peers via the hosts entry in 2configs/wireguard/euer/common.nix,
    # the LAN via the router's *.lan wildcard.
    public_url: "http://nostr-files.euer"
    delete_unaccessed_days: 90
  '';
in
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "route96" ];
    ensureUsers = [
      {
        name = "route96";
        ensurePermissions = {
          "route96.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.route96 = {
    description = "Route96 Nostr blob storage";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "mysql.service"
    ];
    requires = [ "mysql.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${route96}/bin/route96 --config ${configFile}";
      Restart = "on-failure";
      RestartSec = 5;
      # Working directory determines where index.html is loaded from
      WorkingDirectory = "${route96}/share/route96";

      StateDirectory = "route96";
      User = "route96";
      Group = "route96";

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      ReadWritePaths = [ dataDir ];
    };

    preStart = ''
      mkdir -p ${dataDir}/files
    '';
  };

  users.users.route96 = {
    isSystemUser = true;
    group = "route96";
  };
  users.groups.route96 = { };

  services.nginx.virtualHosts."nostr-files.euer" = {
    serverAliases = [ "nostr-files.lan" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        client_max_body_size 100m;
      '';
    };
  };
}
