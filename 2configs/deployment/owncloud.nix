{ lib, pkgs, config, ... }:
with lib;

# services.redis.enable = true;
# to enable caching with redis first start up everything, then run:
# nextcloud-occ config:system:set redis 'host' --value 'localhost' --type string
# nextcloud-occ config:system:set redis 'port' --value 6379 --type integer
# nextcloud-occ config:system:set memcache.local --value '\OC\Memcache\Redis' --type string
# nextcloud-occ config:system:set memcache.locking --value '\OC\Memcache\Redis' --type string

# services.memcached.enable = true;
# to enable caching with memcached run:
# nextcloud-occ config:system:set memcached_servers 0 0 --value 127.0.0.1 --type string
# nextcloud-occ config:system:set memcached_servers 0 1 --value 11211 --type integer
# nextcloud-occ config:system:set memcache.local --value '\OC\Memcache\APCu' --type string
# nextcloud-occ config:system:set memcache.distributed --value '\OC\Memcache\Memcached' --type string

let
  adminpw = "/run/secret/nextcloud-admin-pw";
  dbpw = "/run/secret/nextcloud-db-pw";
in {

  fileSystems."/var/lib/nextcloud/data" = {
    device = "/media/cloud/nextcloud-data";
    options = [ "bind" ];
  };


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
  services.postgresqlBackup = {
    enable = true;
    databases = [ config.services.nextcloud.config.dbname ];
  };
systemd.services.postgresqlBackup-nextcloud.serviceConfig.SupplementaryGroups = [ "download" ];
  
  state = [
    # services.postgresql.dataDir
    # "${config.services.nextcloud.home}/config"
    config.services.postgresqlBackup.location
  ];

  users.users.nextcloud.extraGroups = [ "download" ];
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud22;
    hostName = "o.euer.krebsco.de";
    # Use HTTPS for links
    https = true;
    # Auto-update Nextcloud Apps
    autoUpdateApps.enable = true;
    # Set what time makes sense for you
    autoUpdateApps.startAt = "05:00:00";

    caching.redis = true;
    caching.apcu = true;
    config = {
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";
      defaultPhoneRegion = "DE";

      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      dbpassFile = dbpw;
      adminpassFile = adminpw;
      adminuser = "root";
    };
  };
  services.redis.enable = true;
  systemd.services.redis.serviceConfig.LimitNOFILE=mkForce "65536";
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
