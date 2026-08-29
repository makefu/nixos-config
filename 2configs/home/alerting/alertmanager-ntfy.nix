# alertmanager-ntfy has no NixOS module, so run it as a plain unit.
#
# The tool does not expand env vars in its config, and the config carries the
# ntfy password. To keep the password out of the world-readable nix store, the
# config is rendered at start into the private RuntimeDirectory from a template
# (store) plus the two sops secrets (exposed via systemd credentials).
{ config, pkgs, ... }:
let
  port = 9098;
  # non-secret config with placeholders substituted at runtime
  configTemplate = pkgs.writeText "alertmanager-ntfy.yml.tmpl" ''
    http:
      addr: "127.0.0.1:${toString port}"
    ntfy:
      baseurl: "https://ntfy.euer.krebsco.de"
      notification:
        topic: "alerts"
        priority: "default"
        # Not optional: alertmanager-ntfy dereferences the templates without a
        # nil check (server.go:138), so leaving this out makes it panic on
        # every incoming webhook, answer 500, and spam the journal with a Go
        # stack trace while alertmanager retries forever.
        # Our rules only set `summary`, so description renders empty and the
        # tool falls back to sending the title as the message body.
        templates:
          title: |
            {{ if eq .Status "resolved" }}Resolved: {{ end }}{{ index .Annotations "summary" }}
          description: |
            {{ index .Annotations "description" }}
      auth:
        basic:
          username: "@USER@"
          password: "@PASSWORD@"
  '';
in {
  sops.secrets."omo-alertmanager-ntfy-user" = { };
  sops.secrets."omo-alertmanager-ntfy-password" = { };

  systemd.services.alertmanager-ntfy = {
    description = "Forward Alertmanager notifications to ntfy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "alertmanager.service" ];
    serviceConfig = {
      DynamicUser = true;
      RuntimeDirectory = "alertmanager-ntfy";
      RuntimeDirectoryMode = "0700";
      # systemd copies the sops secrets into $CREDENTIALS_DIRECTORY, readable by
      # the DynamicUser without touching their root-owned /run/secrets originals
      LoadCredential = [
        "user:${config.sops.secrets."omo-alertmanager-ntfy-user".path}"
        "password:${config.sops.secrets."omo-alertmanager-ntfy-password".path}"
      ];
      ExecStartPre = pkgs.writeShellScript "render-alertmanager-ntfy-config" ''
        set -euo pipefail
        user=$(cat "$CREDENTIALS_DIRECTORY/user")
        pass=$(cat "$CREDENTIALS_DIRECTORY/password")
        umask 077
        ${pkgs.gnused}/bin/sed \
          -e "s|@USER@|$user|" \
          -e "s|@PASSWORD@|$pass|" \
          ${configTemplate} > "$RUNTIME_DIRECTORY/config.yml"
      '';
      ExecStart = "${pkgs.alertmanager-ntfy}/bin/alertmanager-ntfy --configs %t/alertmanager-ntfy/config.yml";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
