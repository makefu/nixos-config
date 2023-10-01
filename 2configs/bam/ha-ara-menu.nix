 {pkgs, config, ... }:
let
  pkg = pkgs.ha-ara-menu;
in 
  { 
  sops.secrets.aramarkconfig = {
    mode = "0440";
    group = config.users.groups.ara-secrets.name;
  };
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
