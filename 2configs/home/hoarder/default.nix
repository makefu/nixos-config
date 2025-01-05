# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, config, ... }:
let
  port = 3011;
  hoarder_state_dir = "/media/silent/db/hoarder";
  meili_data_dir = "${hoarder_state_dir}/meili_data";
  hoarder_data_dir = "${hoarder_state_dir}/hoarder_data";
in {
  state = [ hoarder_state_dir ];
  systemd.tmpfiles.settings = {
    "10-hoarder-state-dir" = {
      "${hoarder_state_dir}" = {
        d = {
          group = "root";
          mode = "0700";
          user = "root";
        };
      };
    };
    "10-hoarder-data-dir" = {
      "${hoarder_data_dir}" = {
        d = {
          group = "root";
          mode = "0777";
          user = "root";
        };
      };
    };
    "10-meili-data-dir" = {
      "${meili_data_dir}" = {
        d = {
          group = "root";
          mode = "0777";
          user = "root";
        };
      };
    };
  };

  # nginx proxy config is stored under deployment/hoarder-proxy
  networking.firewall.allowedTCPPorts = [ port ];

  sops.secrets.hoarder-app = {};
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };

  # Enable container name DNS for non-default Podman networks.
  # https://github.com/NixOS/nixpkgs/issues/226365
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."hoarder-chrome" = {
    image = "gcr.io/zenika-hub/alpine-chrome:123";
    cmd = [ "--no-sandbox" "--disable-gpu" "--disable-dev-shm-usage" "--remote-debugging-address=0.0.0.0" "--remote-debugging-port=9222" "--hide-scrollbars" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=chrome"
      "--network=hoarder_default"
    ];
  };
  systemd.services."podman-hoarder-chrome" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-hoarder_default.service"
    ];
    requires = [
      "podman-network-hoarder_default.service"
    ];
    partOf = [
      "podman-compose-hoarder-root.target"
    ];
    wantedBy = [
      "podman-compose-hoarder-root.target"
    ];
  };
  virtualisation.oci-containers.containers."hoarder-meilisearch" = {
    image = "getmeili/meilisearch:v1.11.1";
    environmentFiles = [ config.sops.secrets.hoarder-app.path ];
    environment = {
      "HOARDER_VERSION" = "release";
      "MEILI_NO_ANALYTICS" = "true";
      "NEXTAUTH_URL" = "http://localhost:3000";
    };
    volumes = [
      "${meili_data_dir}:/meili_data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=meilisearch"
      "--network=hoarder_default"
    ];
  };
  systemd.services."podman-hoarder-meilisearch" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-hoarder_default.service"
    ];
    requires = [
      "podman-network-hoarder_default.service"
    ];
    partOf = [
      "podman-compose-hoarder-root.target"
    ];
    wantedBy = [
      "podman-compose-hoarder-root.target"
    ];
  };
  virtualisation.oci-containers.containers."hoarder-web" = {
    image = "ghcr.io/hoarder-app/hoarder:release";
    environmentFiles = [ config.sops.secrets.hoarder-app.path ];
    environment = {
      "BROWSER_WEB_URL" = "http://chrome:9222";
      "DATA_DIR" = "/data";
      "HOARDER_VERSION" = "release";
      "MEILI_ADDR" = "http://meilisearch:7700";
      "NEXTAUTH_URL" = "http://localhost:3000";
    };
    volumes = [
      "${hoarder_data_dir}:/data:rw"
    ];
    ports = [
      "${toString port}:3000/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=web"
      "--network=hoarder_default"
    ];
  };
  systemd.services."podman-hoarder-web" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-hoarder_default.service"
    ];
    requires = [
      "podman-network-hoarder_default.service"
    ];
    partOf = [
      "podman-compose-hoarder-root.target"
    ];
    wantedBy = [
      "podman-compose-hoarder-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-hoarder_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f hoarder_default";
    };
    script = ''
      podman network inspect hoarder_default || podman network create hoarder_default
    '';
    partOf = [ "podman-compose-hoarder-root.target" ];
    wantedBy = [ "podman-compose-hoarder-root.target" ];
  };


  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-hoarder-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
