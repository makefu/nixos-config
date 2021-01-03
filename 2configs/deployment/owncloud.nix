{ lib, pkgs, config, ... }:
with lib;

let
  adminpw = "/run/secret/nextcloud-admin-pw";
  dbpw = "/run/secret/nextcloud-db-pw";
in {
  krebs.secret.files.nextcloud-db-pw = {
    path = dbpw;
    owner.name = "nextcloud";
    source-path = toString <secrets> + "/nextcloud-db-pw";
  };

  krebs.secret.files.nextcloud-admin-pw = {
    path = adminpw;
    owner.name = "nextcloud";
    source-path = toString <secrets> + "/nextcloud-admin-pw";
  };

  services.nginx.virtualHosts."o.euer.krebsco.de" = {
    forceSSL = true;
    enableACME = true;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud20;
    hostName = "o.euer.krebsco.de";
    # Use HTTPS for links
    https = true;
    # Auto-update Nextcloud Apps
    autoUpdateApps.enable = true;
    # Set what time makes sense for you
    autoUpdateApps.startAt = "05:00:00";

    config = {
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";

      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      dbpassFile = dbpw;
      adminpassFile = adminpw;
      adminuser = "admin";
    };
  };

  services.postgresql = {
    enable = true;
    # Ensure the database, user, and permissions always exist
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [ { name = "nextcloud"; ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES"; } ];
  };

  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
