{ config, pkgs, lib, ...}:
let
  port = "3008";
in
  {
  networking.firewall.allowedTCPPorts = [ 3008 ];
  sops.secrets.mdrss-environment = {};
  services.nginx.virtualHosts."mdrss" = {
    serverAliases = [ "mdrss.euer.krebsco.de" ];
    locations."/" = {
      proxyPass = "http://localhost:${port}";
      proxyWebsockets = true;
    };
  };

  virtualisation.oci-containers.containers.mdrss-postgres = {
    image = "postgres:17";
    environmentFiles = [
      # contains POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB
      config.sops.secrets.mdrss-environment.path
    ];
    extraOptions = [
      "--network-alias=postgres"
      "--network=mdrss_default"
    ];
  };


  virtualisation.oci-containers.containers.mdrss = {
    image = "makefoo/mdrss-ts:1.0.1";
    ports = [ "${port}:3000" ];
    environmentFiles = [
      # contains DB_URL which matches postgres config
      config.sops.secrets.mdrss-environment.path
    ];
    extraOptions = [
      "--network-alias=mdrss"
      "--network=mdrss_default"
    ];
  };
  # network and startup sorting
  systemd.services."podman-network-mdrss_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f mdrss_default";
    };
    script = ''
      podman network inspect mdrss_default || podman network create mdrss_default
    '';
  };
  systemd.targets."podman-compose-podman-mdrss-root" = {
    unitConfig = {
      Description = "Root target for mdrss";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services."podman-mdrss-postgres" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mdrss_default.service"
    ];
    requires = [
      "podman-network-mdrss_default.service"
    ];
    partOf = [
      "podman-compose-mdrss-root.target"
    ];
    wantedBy = [
      "podman-compose-mdrss-root.target"
    ];
  };
  systemd.services."podman-mdrss" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-mdrss_default.service"
      "podman-mdrss-postgres.service"
    ];
    requires = [
      "podman-network-mdrss_default.service"
    ];
    partOf = [
      "podman-compose-mdrss-root.target"
    ];
    wantedBy = [
      "podman-compose-mdrss-root.target"
    ];
  };
}
