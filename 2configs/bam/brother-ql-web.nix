 {pkgs, inputs, ... }:
 let
  pkg = inputs.brother_ql_web.packages.${pkgs.system}.default;
 in { 
  systemd.services.brother-ql-web = {
    after = [ "network.target" ];
    description = "Brother QL Web Interface";
    wantedBy = [ "multi-user.target" ];
    environment = {
      #FLASK_PRINTER = "usb://0x04f9:0x209b/000F1Z401759";
      FLASK_PRINTER = "usb://0x04f9:0x209d/000F1Z399583";
      FLASK_MODEL = "QL-820NWB";
      #FLASK_SERVER_PORT = "8013";
      #FLASK_LABEL_DEFAULT_SIZE = "d24";
      #FLASK_LABEL_DEFAULT_QR_SIZE = "7";
    };
    serviceConfig = {
        ExecStart = "${pkg}/bin/brother_ql_web";
        DynamicUser = true;
        SupplementaryGroups = "lp";
        Restart = "always";
    };
  };
}
