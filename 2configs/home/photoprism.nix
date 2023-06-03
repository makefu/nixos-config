{ pkgs, lib, ...}:
# Start    | docker-compose up -d
# Stop     | docker-compose stop
# Update   | docker-compose pull
# Logs     | docker-compose logs --tail=25 -f
# Terminal | docker-compose exec photoprism bash
# Help     | docker-compose exec photoprism photoprism help
# Config   | docker-compose exec photoprism photoprism config
# Reset    | docker-compose exec photoprism photoprism reset
# Backup   | docker-compose exec photoprism photoprism backup -a -i
# Restore  | docker-compose exec photoprism photoprism restore -a -i
# Index    | docker-compose exec photoprism photoprism index
# Reindex  | docker-compose exec photoprism photoprism index -a
# Import   | docker-compose exec photoprism photoprism import
# -------------------------------------------------------------------
let
  port = "2347";
  photodir = "/media/cryptX/photos";
  statedir = "/media/cryptX/lib/photoprism/appsrv";
  db-dir = "/media/cryptX/lib/photoprism/mysql";
  internal-ip = "192.168.111.11";
  sec = import <secrets/photoprism.nix>;
in
{
  virtualisation.oci-containers.backend = "docker";

  services.nginx.virtualHosts."photos" = {
    serverAliases = [
              "photos.lan"
      "foto"  "foto.lan"
      "fotos" "fotos.lan"
    ];

    locations."/".proxyPass = "http://localhost:${port}";
    locations."/".proxyWebsockets = true;
    extraConfig = ''
      if ( $server_addr != "${internal-ip}" ) {
        return 403;
      }
    '';
  };

  systemd.services.workadventure-network = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.docker}/bin/docker network create --driver bridge photoprism ||:
    '';
    after = [ "docker.service" ];
    before = [
      "docker-photoprism.service"
      "docker-mysql-photoprism.service"
    ];
  };


  virtualisation.oci-containers.containers.photoprism = {
    image = "photoprism/photoprism:preview";
    ports = ["${port}:${port}" ];
    volumes = [
      "${photodir}:/photoprism/originals"
      "${statedir}:/photoprism/storage"
    ];
    extraOptions = [
      "--security-opt" "seccomp=unconfined"
      "--security-opt" "apparmor=unconfined"
      "--network=photoprism"
    ];
    environment = {
      PHOTOPRISM_HTTP_PORT = port;                     # Built-in Web server port
      PHOTOPRISM_HTTP_COMPRESSION = "gzip";            # Improves transfer speed and bandwidth utilization (none or gzip)
      PHOTOPRISM_DEBUG = "false";                      # Run in debug mode (shows additional log messages)
      # PHOTOPRISM_PUBLIC = "true";                      # No authentication required (disables password protection)
      PHOTOPRISM_READONLY = "false";                   # Don't modify originals directory (reduced functionality)
      PHOTOPRISM_EXPERIMENTAL = "true";                # Enables experimental features
      # PHOTOPRISM_DISABLE_WEBDAV = "false";             # Disables built-in WebDAV server
      PHOTOPRISM_DISABLE_SETTINGS = "false";           # Disables Settings in Web UI
      PHOTOPRISM_DISABLE_TENSORFLOW = "false";         # Disables using TensorFlow for image classification
      PHOTOPRISM_DARKTABLE_PRESETS = "false";          # Enables Darktable presets and disables concurrent RAW conversion
      PHOTOPRISM_DETECT_NSFW = "false";                # Flag photos as private that MAY be offensive (requires TensorFlow)
      PHOTOPRISM_UPLOAD_NSFW = "true";                 # Allow uploads that MAY be offensive
      PHOTOPRISM_AUTH_MODE = "password";
      PHOTOPRISM_ADMIN_USER = "admin";
      PHOTOPRISM_ADMIN_PASSWORD = "admin";

      #PHOTOPRISM_DATABASE_DRIVER = "postgres";
      #PHOTOPRISM_DATABASE_SERVER = "postgres-prism:5432";
      #PHOTOPRISM_DATABASE_NAME = "photoprism";
      #PHOTOPRISM_DATABASE_USER = "photoprism";
      #PHOTOPRISM_DATABASE_PASSWORD = "photoprism";

      PHOTOPRISM_DATABASE_DRIVER= "mysql";           # Use MariaDB (or MySQL) instead of SQLite for improved performance
      PHOTOPRISM_DATABASE_SERVER= "mysql-photoprism:3306" ;   # MariaDB database server (hostname:port)
      PHOTOPRISM_DATABASE_NAME= "photoprism";        # MariaDB database schema name
      PHOTOPRISM_DATABASE_USER= sec.db.username;        # MariaDB database user name
      PHOTOPRISM_DATABASE_PASSWORD= sec.db.password;      # MariaDB database user password

      PHOTOPRISM_SITE_URL = "http://localhost:2342/";  # Public PhotoPrism URL
      PHOTOPRISM_SITE_TITLE = "PhotoPrism";
      PHOTOPRISM_SITE_CAPTION = "FeMi Fotos";
      PHOTOPRISM_SITE_DESCRIPTION = "Unsere Fotos";
      PHOTOPRISM_SITE_AUTHOR = "FeMi";
      PHOTOPRISM_SPONSOR = "true";

    };
  };

  virtualisation.oci-containers.containers.mysql-photoprism = {
    image = "mariadb:10.5";
    extraOptions = [
      "--security-opt" "seccomp=unconfined"
      "--security-opt" "apparmor=unconfined"
      "--network=photoprism"
    ];
    ports = [ "3306:3306" ]; # no need to expose the database
    #cmd = [ "mysqld"
    #  "--transaction-isolation=READ-COMMITTED"
    #  "--character-set-server=utf8mb4"
    #  "--collation-server=utf8mb4_unicode_ci"
    #  "--max-connections=512"
    #  "--innodb-rollback-on-timeout=OFF"
    #  "--innodb-lock-wait-timeout=50"
    #];
    volumes= [ "${db-dir}:/var/lib/mysql" ];
    environment = {
      MYSQL_ROOT_PASSWORD = "dickidibutt";
      MYSQL_DATABASE= "photoprism";
      MYSQL_USER = sec.db.username;
      MYSQL_PASSWORD = sec.db.password;
    };
  };
  #virtualisation.oci-containers.containers.postgres-prism = {
  #  image = "postgres:12-alpine";
  #  ports = [ "5432" ]; # no need to expose the database
  #  environment = {
  #    POSTGRES_DB = "photoprism";
  #    POSTGRES_USER = "photoprism";
  #    POSTGRES_PASSWORD = "photoprism";
  #  };
  #};

  systemd.services.docker-photoprism.serviceConfig = {
    StandardOutput = lib.mkForce "journal";
    StandardError = lib.mkForce "journal";
  };
  systemd.services.docker-mysql-photoprism.serviceConfig = {
    StandardOutput = lib.mkForce "journal";
    StandardError = lib.mkForce "journal";
  };
}
