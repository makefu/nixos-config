 {pkgs, config, ... }:
let
  pkg = pkgs.inventory4ce;
in 
{ 
  users.groups.inventory-secrets = {};

  sops.secrets.inventory_cert = {
    mode = "0440";
    group = config.users.groups.inventory-secrets.name;
  };
  sops.secrets.inventory_key = {
    mode = "0440";
    group = config.users.groups.inventory-secrets.name;
  };
  systemd.services.inventory4ce = {
    description = "inventory4ce";
    wantedBy = [ "multi-user.target" ];
    environment = {
      INVENTORY_CERT = config.sops.secrets."inventory_cert".path;
      INVENTORY_KEY = config.sops.secrets."inventory_key".path;
      INVENTORY_PORT = "3001";
      INVENTORY_HOST = "0";
    };
    serviceConfig = {
      StateDirectory = "inventory4ce";
      WorkingDirectory = "/var/lib/inventory4ce";
      ExecStart = "${pkg}/bin/inventory4ce";
      DynamicUser = true;
      SupplementaryGroups = [ config.users.groups.inventory-secrets.name ];
      Restart = "always";
    };
  };
}
