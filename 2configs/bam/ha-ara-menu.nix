 {pkgs,ha-ara-menu, ... }:
 let
   pkg = ha-ara-menu.packages.default;
 in { 
  systemd.services.ha-ara-menu = {
    after = [ "mosquitto.service" ];
    description = "ha-ara-menu";
    wantedBy = [ "multi-user.target" ];
    environment = {
    };
    serviceConfig = {
        ExecStart = "${pkg}/bin/ha-ara-menu";
        DynamicUser = true;
        Restart = "always";
    };
  };
}
