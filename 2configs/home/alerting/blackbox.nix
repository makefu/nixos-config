# Shared blackbox_exporter for the checks under ./checks/.
#
# All probe modules live in one config file, but that file cannot be built
# into the nix store: the inference.p0.contact probe carries the bearer token
# and blackbox neither expands env vars nor accepts the token anywhere else.
# Like ./alertmanager-ntfy.nix, the config is rendered at unit start from a
# template (store) plus the sops secret (systemd credential).
{ config, pkgs, ... }:
let
  # RuntimeDirectory=blackbox-exporter -> $RUNTIME_DIRECTORY is
  # /run/blackbox-exporter (systemd does NOT prefix the unit name)
  runtimeConfig = "/run/blackbox-exporter/blackbox.yml";
  # non-secret config with the token substituted at start
  configTemplate = pkgs.writeText "blackbox.yml.tmpl" (
    builtins.toJSON {
      # plain https probe (see ./checks/web.nix)
      modules.http_2xx = {
        prober = "http";
        timeout = "10s";
        http = {
          method = "GET";
          fail_if_not_ssl = true;
          # empty -> default to 2xx
          valid_status_codes = [ ];
        };
      };
      # authenticated probe for the vLLM endpoint (see ./checks/inference.nix)
      modules.http_bearer = {
        prober = "http";
        timeout = "10s";
        http = {
          method = "GET";
          fail_if_not_ssl = true;
          headers.Authorization = "Bearer @TOKEN@";
        };
      };
    }
  );
in {
  services.prometheus.exporters.blackbox = {
    enable = true;
    port = 9115;
    listenAddress = "127.0.0.1";
    # rendered at unit start; nothing in the store to check
    configFile = runtimeConfig;
    enableConfigCheck = false;
  };

  systemd.services."prometheus-blackbox-exporter".serviceConfig = {
    RuntimeDirectory = "blackbox-exporter";
    RuntimeDirectoryMode = "0700";
    # same secret opencrow uses for this endpoint; systemd copies it into
    # $CREDENTIALS_DIRECTORY, readable by the exporter's DynamicUser without
    # touching the root-owned /run/secrets original
    LoadCredential = [
      "token:${config.sops.secrets.opencrow-vllm-api-key.path}"
    ];
    ExecStartPre = pkgs.writeShellScript "render-blackbox-config" ''
      set -euo pipefail
      token=$(cat "$CREDENTIALS_DIRECTORY/token")
      umask 077
      ${pkgs.gnused}/bin/sed -e "s|@TOKEN@|$token|" \
        ${configTemplate} > "$RUNTIME_DIRECTORY/blackbox.yml"
    '';
  };
}
