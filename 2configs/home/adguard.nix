{config, ... }:
let
    itf = config.makefu.server.primary-itf;
    port = 3688;
in {
    services.adguardhome = {
        enable = true;
        inherit port;
        mutableSettings = true;
    };
    networking.firewall = {
        allowedUDPPorts = [ 53 ];
        interfaces."${itf}".allowedTCPPorts = port;
    };
}
