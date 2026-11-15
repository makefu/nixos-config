{
  config,
  lib,
  ...
}:
let
  # hermes gateway/webapp_listener.py defaults; kept explicit so nginx and the
  # settings block cannot drift apart.
  webappPort = 9120;
  # Canonical hostname. The webapp listener's Host/Origin gate
  # (hermes_cli/web_server_boundary.py) trusts ONLY webapp.public_url's host
  # plus the bound loopback address — a second vhost hostname would be
  # rejected with 400 (HTTP) or origin_mismatch (WS). So every proxy below
  # rewrites Host AND Origin to this one; sessions are stateless HMAC
  # cookies minted by the basic provider (no OAuth redirect), which makes the
  # rewrite safe. Browsers store the cookie per visited host, so LAN and euer
  # each need one login.
  webappHost = "hermes.euer.syntax-fehler.de";
  publicUrl = "https://${webappHost}";
  hermesLocations = {
    "/" = {
      proxyPass = "http://127.0.0.1:${toString webappPort}";
      proxyWebsockets = true; # /api/pty + /api/ws; module adds Upgrade/Connection
      # the module's recommended include sets `proxy_set_header Host $host;`
      # which would defeat the canonical-Host rewrite; all headers explicit below
      recommendedProxySettings = false;
      # no semicolons inside these comments: nginx joins extraConfig lines and
      # a `;` mid-comment makes the rest of the line a directive
      extraConfig = ''
        proxy_set_header Host ${webappHost};
        proxy_set_header Origin "${publicUrl}";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # Secure-cookie decision honours X-Forwarded-Proto (loopback binds are
        # always trusted for proxy headers, so no dashboard.trusted_proxies needed)
        proxy_set_header X-Forwarded-Proto $scheme;
        # browser attachments are capped at 16 MiB (WEBAPP_ATTACHMENT_MAX_BYTES)
        client_max_body_size 20m;
        # long hermes tool turns must not be cut at the 60s proxy_read_timeout default
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
      '';
    };
  };
in
{
  # dotenv consumed by the gateway's load_hermes_dotenv() at process start:
  #   clan secrets set --machine omo --user makefu hermes-webapp-basic-auth-env
  #   HERMES_DASHBOARD_BASIC_AUTH_USERNAME=makefu
  #   HERMES_DASHBOARD_BASIC_AUTH_PASSWORD_HASH='scrypt$16384$8$1$<salt_b64>$<dk_b64>'
  #   HERMES_DASHBOARD_BASIC_AUTH_SECRET='<64 hex>'
  # Values are single-quoted: python-dotenv interpolates $VAR only inside double
  # quotes, so ' or bare both survive the scrypt string's $ segments — ' is the
  # safe form. The env names are what plugins/dashboard_auth/basic resolves via
  # resolve_env_or_cfg (config.yaml `dashboard.basic_auth` is the equivalent
  # canonical surface, but a hash+secret there would land in the nix store).
  # HERMES_DASHBOARD_BASIC_AUTH_SECRET makes the HMAC session tokens survive
  # gateway restarts.
  # restartUnits: dotenv is read by the gateway at process start only; content
  # changes do not trip the path-hashing restartTriggers.
  sops.secrets."hermes-webapp-basic-auth-env" = {
    restartUnits = [ "hermes-agent.service" ];
  };

  services.hermes-agent = {
    environmentFiles = [ config.sops.secrets."hermes-webapp-basic-auth-env".path ];
    # Deep-merged with agent.nix's settings into $HERMES_HOME/config.yaml at
    # activation; the gateway reads `webapp:` only at process start, so the
    # restartTriggers below carry a settings hash (open-webui.nix hashes
    # environment/environmentFiles; neither covers toggling webapp).
    settings.webapp = {
      enabled = true;
      # local-only bind: reachable externally solely through the nginx vhosts.
      # A non-loopback public_url keeps the auth gate engaged even on loopback
      # binds (web_server.py _dashboard_auth_gate).
      host = "127.0.0.1";
      port = webappPort;
      public_url = publicUrl;
    };
  };

  systemd.services.hermes-agent.restartTriggers = lib.mkAfter [
    (builtins.toJSON { inherit (config.services.hermes-agent) settings; })
  ];

  # TLS: relayed LE wildcards from gum (3modules/cert-relay.nix) —
  # https://hermes.euer.syntax-fehler.de + https://hermes.lan.syntax-fehler.de
  makefu.cert-relay.euer.client.nginxVhosts.hermes = {
    locations = hermesLocations;
  };
  makefu.cert-relay.lan.client.nginxVhosts.hermes = {
    locations = hermesLocations;
  };

  # plain HTTP for wireguard/LAN-internal access, mirroring the agent.euer
  # pattern in open-webui.nix (euer hosts entries in
  # 2configs/wireguard/euer/common.nix; *.lan from the router DNS)
  services.nginx.virtualHosts."hermes.euer" = {
    serverAliases = [ "hermes.lan" ];
    locations = hermesLocations;
  };
}
