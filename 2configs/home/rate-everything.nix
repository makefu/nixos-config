{ pkgs, inputs, config, ... }:
let
    outdir = "/var/lib/rate-everything";
    port = 3002;
    # sslport = 3102;
    # ty on current nixpkgs flags 127 pre-existing diagnostics in the
    # project's installCheckPhase and fails the build; skip the check until
    # upstream rate-everything is ty-clean.
    pkg = (inputs.rate-everything.packages.${pkgs.stdenv.hostPlatform.system}.default).overrideAttrs (_: {
      doInstallCheck = false;
    });
in {
  sops.secrets."rate-everything_secrets" = {};
  systemd.services.rate-everything = {
    description = "rate-everything";
    wantedBy = [ "multi-user.target" ];
    environment = {
      RATE_EVERYTHING_PORT = toString port;
      RATE_EVERYTHING_DATA_DIR = outdir;
      RATE_EVERYTHING_TIMEOUT = "300";
      DB_PATH = "${outdir}/db.sqlite3";
      MEDIA_ROOT = "${outdir}/media";
      STT_WHISPER_CACHEDIR = "${outdir}/whisper";
      HOME = outdir; # set for whisper download dir
      WITH_SSL = "true"; # testing only
      ALLOWED_HOSTS = "*"; # testing only
      STT_BACKEND = "mistral_voxtral"; #apikey in SECRETS_FILE
      SECRETS_FILE = "/run/credentials/rate-everything.service/secrets";
    };
    serviceConfig = {
      LoadCredential = "secrets:${config.sops.secrets."rate-everything_secrets".path}";
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
