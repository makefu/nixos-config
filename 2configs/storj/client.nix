{ lib, ... }:
let
  port = "14002";
  internal-ip = "192.168.111.11";
in
{
  networking.firewall.allowedTCPPorts = [ 28967 ];
  virtualisation.oci-containers.containers.storj-storagenode = {
    image = "storjlabs/storagenode:latest";
    ports = [
      # TODO: omo ip
      "0.0.0.0:28967:28967"
      "127.0.0.1:${port}:${port}"
    ];
    environment = {
      # SETUP = "true"; # must be run only once ...
      WALLET = "0xeD0d2a2B33F6812b45d2D9FF7a139A3fF65a24C0";
      EMAIL = "storj.io@syntax-fehler.de";
      ADDRESS = "euer.krebsco.de:28967";
      STORAGE = "3TB";
    };
    volumes = [
      "/media/cryptX/lib/storj/identity:/app/identity"
      "/media/cryptX/lib/storj/storage:/app/config"
    ];
  };
  systemd.services.docker-storj-storagenode.serviceConfig = {
    StandardOutput = lib.mkForce "journal";
    StandardError = lib.mkForce "journal";
  };

  services.nginx.virtualHosts."storj" = {
    serverAliases = [
              "storj.lan"
    ];

    locations."/".proxyPass = "http://localhost:${port}";
    locations."/".proxyWebsockets = true;
    extraConfig = ''
      if ( $server_addr != "${internal-ip}" ) {
        return 403;
      }
    '';
  };
}
