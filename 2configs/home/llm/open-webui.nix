{
  config,
  pkgs,
  lib,
  ...
}:
let
  openWebuiPort = 8180;
  apiServerPort = 8642; # hermes api_server default
  # open-webui 0.12.3 pins mcp==1.27.2; nixpkgs `mcp` is 2.3.0, which dropped
  # mcp.client.streamable_http.streamablehttp_client (ImportError at serve).
  # nixpkgs ships the 1.x line as mcp_1 (1.29.0) for exactly this consumer.
  openWebuiPackage = pkgs.open-webui.override {
    python3Packages = pkgs.python3Packages.override {
      overrides = self: super: {
        mcp = self.mcp_1;
      };
    };
  };
  # one proxy body, reused for the plain vhost and both relayed TLS vhosts
  openWebuiLocations = {
    "/" = {
      proxyPass = "http://127.0.0.1:${toString openWebuiPort}";
      proxyWebsockets = true; # open-webui uses socket.io; nginx module provides $connection_upgrade
      # no semicolons inside these comments: nginx joins extraConfig lines and
      # a `;` mid-comment makes the rest of the line a directive ("vhost default…")
      extraConfig = ''
        # 50m for file uploads / RAG ingestion
        client_max_body_size 50m;
        # long hermes tool turns must not be cut at the 60s proxy_read_timeout default
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
      '';
    };
  };
in
{
  imports = [
    ../../cert-relay/client-euer.nix
    ../../cert-relay/client-lan.nix
  ];
  # Two dotenv files, merged into $HERMES_HOME/.env / systemd EnvironmentFile at activation.
  #   clan secrets set --machine omo --user makefu hermes-api-server-env
  #   clan secrets set --machine omo --user makefu open-webui-env
  # Same key value on both sides: open-webui presents it as the OpenAI key to hermes.
  sops.secrets."hermes-api-server-env" = { };
  sops.secrets."open-webui-env" = { };

  # ── hermes side: enable the OpenAI-compatible api_server platform ──
  # _api_server (gateway/config_env.py) enables the platform iff API_SERVER_KEY is usable
  # (>=16 chars); host/port/model-name come from these env extras. Do not add a
  # settings.platforms.api_server block: config.yaml's explicit marker would fight the
  # env path, and the defaults (127.0.0.1:8642, model "hermes-agent") are what we want.
  services.hermes-agent = {
    environmentFiles = [ config.sops.secrets."hermes-api-server-env".path ];
    environment = {
      API_SERVER_HOST = "127.0.0.1";
      API_SERVER_PORT = toString apiServerPort;
    };
    # .env is written by system.activationScripts."hermes-agent-setup"
    # (nixosModules.nix:456,484 -> common.mkStateScript) at switch time and read by the
    # gateway only at process start. containerIdentity hashes image/volumes/options only
    # and the unit defines no restartTriggers (module has no systemdServices option —
    # verified by grep), so set them directly on the unit: without this a rotated key
    # would sit in .env until the next unrelated restart.
  };

  systemd.services.hermes-agent.restartTriggers = lib.mkAfter [
    (builtins.toJSON {
      inherit (config.services.hermes-agent) environment environmentFiles;
    })
  ];

  # ── open-webui ──
  services.open-webui = {
    enable = true;
    package = openWebuiPackage; # mcp pinned to mcp_1; posthog unbroken by 6hotfix/posthog.nix
    host = "127.0.0.1"; # nginx-only reachability, like every other service on omo
    port = openWebuiPort;
    environmentFile = config.sops.secrets."open-webui-env".path;
    environment = {
      # OpenAI wiring deliberately NOT here — the dotenv supplies
      # OPENAI_API_KEY/OPENAI_API_BASE_URL instead (the key must not land in the
      # Nix store; and config.py resets the singular vars after seeding the
      # plural lists that feed DEFAULT_CONFIG/DB).
      ENABLE_OLLAMA_API = "False"; # no ollama on omo; stops the 11434 probe
      WEBUI_AUTH = "True";
      ENABLE_SIGNUP = "False"; # admin bootstrapped from WEBUI_ADMIN_* in environmentFile
      WEBUI_NAME = "Hermes";
      # absolute URLs in emails/links/oauth; module default is http://localhost:port
      WEBUI_URL = "https://agent.lan.syntax-fehler.de";
    };
    # RAG embedding model (sentence-transformers/all-MiniLM-L6-v2) downloads from
    # HF into HF_HOME=${stateDir}/hf_home on first start; leave the defaults.
  };

  # ── TLS: relayed LE wildcards from gum via cert-relay (3modules/cert-relay.nix) ──
  # produce https://agent.euer.syntax-fehler.de + https://agent.lan.syntax-fehler.de
  makefu.cert-relay.euer.client.nginxVhosts.agent = {
    locations = openWebuiLocations;
  };
  makefu.cert-relay.lan.client.nginxVhosts.agent = {
    locations = openWebuiLocations;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      # plain HTTP for wireguard/LAN-internal access, mirroring the nostr.euer pattern
      # (2configs/home/nostr-relay.nix). euer members resolve agent.euer via the hosts
      # entries in 2configs/wireguard/euer/common.nix; *.lan from the router.
      "agent.euer" = {
        serverAliases = [ "agent.lan" ];
        locations = openWebuiLocations;
      };
    };
  };
}
