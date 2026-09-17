{config, lib, ... }:
let
  metadataKeys = [
    "priority"
    "syslog_identifier"
    "pid"
    "container_name"
  ];
  labelKeys = [
    "host"
    "unit"
    "coredump_unit"
  ];

  passwordFile = config.sops.secrets.loki-auth.path;
in {
  systemd.services.fluent-bit = {
    serviceConfig = {
      # Safety net: the wasm filter instance is persistent and wasm linear
      # memory never shrinks, so restart daily to bound memory growth.
      RuntimeMaxSec = "1d";
      StateDirectory = "fluent-bit";
      RuntimeDirectory = "fluent-bit";
      LoadCredential = "loki-password:${passwordFile}";
      EnvironmentFile = "-/run/fluent-bit/env";
    };
    # fluent-bit's loki output cannot read the password from a file, so turn the
    # credential into an env var before the main process starts.
    preStart = ''
      umask 0077
      printf 'LOKI_PASSWORD=%s\n' "$(cat "$CREDENTIALS_DIRECTORY/loki-password")" \
        > /run/fluent-bit/env
    '';
  };
  services.fluent-bit = {
    enable = true;
    settings = {
      pipeline = {
        inputs = [
          {
            name = "systemd";
            tag = "host.*";
            systemd_filter = "_SYSTEMD_UNIT=tincr-retiolum.service";
						#db = "/var/lib/fluent-bit/journal.db";
            read_from_tail = "on";
            max_entries = 1;
            strip_underscores = "off";
						#"storage.type" = "filesystem";
          }
        ];
        filters = [
          {
            # journald attaches ~25 fields (_BOOT_ID, _MACHINE_ID, ...);
            # keep only what ends up in loki
            name = "record_modifier";
            match = "*";
            allowlist_key = [
              "MESSAGE"
              "PRIORITY"
            ];
          }
        ];
        outputs = [
          {
            name = "loki";
            match = "*";
            host = "loki.r";
            port = 80;
            uri = "/loki/api/v1/push";
            http_user = "promtail-makefu";
            http_passwd = "\${LOKI_PASSWORD}";
            labels = "job=systemd-journal,host=${config.networking.hostName},unit=tincr-retiolum.service";
            drop_single_key = "raw";
            structured_metadata = "priority=$PRIORITY";
            remove_keys = "PRIORITY";
            line_format = "key_value";
          }
        ];
      };
    };
  };
}
