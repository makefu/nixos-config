{ pkgs, inputs, ... }:
let
    outdir = "/var/lib/rate-everything";
    port = 3002;
    # sslport = 3102;
    pkg = inputs.rate-everything.packages.${pkgs.system}.default;
in {
  systemd.services.rate-everything = {
    description = "rate-everything";
    wantedBy = [ "multi-user.target" ];
    environment = {
      RATE_EVERYTHING_PORT = toString port;
      RATE_EVERYTHING_DATA_DIR = outdir;
      RATE_EVERYTHING_TIMEOUT = "300";
      DB_PATH = "${outdir}/db.sqlite3";
      MEDIA_ROOT = "${outdir}/media";
      WITH_SSL = "true"; # testing only
      ALLOWED_HOSTS = "*"; # testing only
    };
    serviceConfig = {
      StateDirectory = "rate-everything";
      WorkingDirectory = outdir;
      ExecStartPre = "${pkg}/bin/rate-everything migrate";
      ExecStart = "${pkg}/bin/rate-everything";
      DynamicUser = true;
      Restart = "always";
    };
};

  networking.firewall.allowedTCPPorts = [ port ];
  services.nginx.virtualHosts."rate-everything" = {
      serverAliases = [ "rate.lan" ];
      #addSSL = true;
      #listen = [
      #    { port = sslport; ssl = true; }
      #];

    locations."/".proxyPass = "https://localhost:${toString port}";
    locations."/".proxyWebsockets = true;
  };
}
