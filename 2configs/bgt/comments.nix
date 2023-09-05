let
  configFile = config.sops.secrets."isso.conf".path;
in {
  sops.secrets."isso.conf" = {
    owner = "isso";
    group = "isso";
  };

  services.isso.enable = true;
  # override the startup to allow secrets in the configFile
  # following relevant config is inside:
  # [general]
  # dbpath = /var/lib/comments.db
  # host = https://blog.binaergewitter.de
  # listen = http://localhost:9292
  # public-endpoint = https://comments.binaergewitter.de
  systemd.services.isso.serviceConfig.ExecStart = "${pkgs.isso}/bin/isso -c ${configFile}" ;

  services.nginx.virtualHosts."comments.binaergewitter.de" = {
    forceSSL = true;
    enableAcme = true;
    useACMEHost = "download.binaergewitter.de";
    locations."/".proxyPass = "http://localhost:9292";
  };

}
