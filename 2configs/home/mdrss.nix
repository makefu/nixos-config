{ config, pkgs, lib, ...}:
let
  port = "3008";
in
{
  sops.secrets.mdrss-environment = {};
  services.nginx.virtualHosts."mdrss" = {
    serverAliases = [ "mdrss.euer.krebsco.de" ];
    locations."/" = {
      proxyPass = "http://localhost:${port}";
      proxyWebsockets = true;
    };
  };

  virtualisation.oci-containers.containers.mdrss-postgres = {
    image = "postgres:18";
    environmentFiles = [
      # contains POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB
      sops.secrets.mdrss-environment.path
    ];
  };

  virtualisation.oci-containers.containers.mdrss = {
    image = "makefoo/mdrss:1.0.1";
    ports = [ "${port}:3000" ];
    environmentFiles = [
      # contains DB_URL which matches postgres config
      sops.secrets.mdrss-environment.path
    ];
  };
}
