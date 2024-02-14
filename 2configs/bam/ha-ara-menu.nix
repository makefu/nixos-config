 {pkgs, config, inputs, ... }:
let
  pkg = inputs.ha-ara-menu.packages.${pkgs.system}.default;
in 
  { 
  sops.secrets.aramarkconfig = {
    mode = "0440";
    group = config.users.groups.ara-secrets.name;
  };
  users.groups.ara-secrets = {};

  systemd.services.ha-ara-menu = {
    description = "ha-ara-menu";
    wantedBy = [ "multi-user.target" ];
    environment = {
      ARAMARKCONFIG = config.sops.secrets."aramarkconfig".path;
    };
    startAt = "*:0/30";
    serviceConfig = {
      ExecStart = "${pkg}/bin/send";
      DynamicUser = true;
      SupplementaryGroups = [ config.users.groups.ara-secrets.name ];
    };
  };
}
