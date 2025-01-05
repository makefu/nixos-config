{ config, lib, pkgs, ... }:


let
  stockholm = pkgs.stockholm;
  ident = (builtins.readFile ../auphonic.pub);
  nginxlogs = "/var/log/nginx";
  bgtaccess = "${nginxlogs}/binaergewitter.access.log";
  bgterror =  "${nginxlogs}/binaergewitter.error.log";

  # TODO: only when the data is stored somewhere else
in {
  # 
  state = [ bgtaccess bgterror ];
  sops.secrets."bgtmetrics.htaccess".owner = "nginx";
  sops.secrets."maxmind-geoip" = {};
  services.openssh = {
    allowSFTP = true;
    sftpFlags = [ "-l VERBOSE" ];
    extraConfig = ''
      HostkeyAlgorithms +ssh-rsa

      Match User auphonic
        ForceCommand internal-sftp
        AllowTcpForwarding no
        X11Forwarding no
        PasswordAuthentication no
        PubkeyAcceptedAlgorithms +ssh-rsa

    '';
  };

  users.users.auphonic = {
    uid = stockholm.lib.genid "auphonic";
    group = "nginx";
    # for storedir
    extraGroups = [ "download" ];
    useDefaultShell = true;
    isSystemUser = true;
    openssh.authorizedKeys.keys = [ ident config.krebs.users.makefu.pubkey ];
  };

  # services.logrotate is configured by nginx, increase log rotation to 1 year
  services.logrotate.settings.nginx.rotate = 54;


  # 20.09 unharden nginx to write logs
  systemd.services.nginx.serviceConfig.ReadWritePaths = [ nginxlogs ];
  systemd.tmpfiles.rules = [ "d ${nginxlogs} 0700 nginx root - -" ];

  systemd.services.generate-metrics = {
    startAt = "/30";
    path = [ pkgs.goaccess ];
    serviceConfig.User = config.services.nginx.user;
    script = ''
      goaccess binaergewitter.access.log* --log-format=COMBINED -o /var/www/binaergewitter/metrics/index.html
    '';
  };

  services.geoipupdate = {
    enable = true;
    settings = {
      AccountID = 1107103;
      LicenseKey = config.sops.secrets."maxmind-geoip".path;
      EditionIDs = [
        #"GeoLite2-ASN"
        "GeoLite2-City"
        #"GeoLite2-Country"
      ];
    };
  };

  services.nginx = {
    enable = lib.mkDefault true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    additionalModules = [ pkgs.nginxModules.geoip2 ];

    # Define log format in the http context

    # $http_x_forwarded_for - $remote_user
    # $remote_addr
    # $geoip2_data_country_code
    commonHttpConfig = ''

      geoip2 ${config.services.geoipupdate.settings.DatabaseDirectory}/GeoLite2-City.mmdb {
        $geoip2_data_city_name source=$http_x_forwarded_for  default=Unbekannt city names de;
        $geoip2_data_country_code source=$http_x_forwarded_for default=DE country iso_code;
        $geoip2_data_country_name source=$http_x_forwarded_for default=Deutschland country names de;
      }

      log_format goaccess '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent" - $geoip2_data_country_code $geoip2_data_city_name';
    '';

    # using letsencrypt certificate without cloudflare

    virtualHosts."podcast.savar.de" = {
      serverAliases = [ "download.binaergewitter.de" "dl.binaergewitter.de" "dl1.binaergewitter.de" "dl2.binaergewitter.de" "binaergewitter.jit.computer" ];
      root = "/var/www/binaergewitter";
      extraConfig = ''
        access_log ${bgtaccess} goaccess;
        error_log ${bgterror} error;
        autoindex on;
        add_header 'Access-Control-Allow-Origin' '*';

      '';
      locations."/metrics" = {
        basicAuthFile = config.sops.secrets."bgtmetrics.htaccess".path;
      };
    };
  };
}
