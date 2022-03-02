let
  internal-ip = "192.168.111.11";
in
{
  services.nginx.virtualHosts."ps4srv" = {
    serverAliases = [
              "ps4srv.lan"
    ];

    locations."/".root = "/media/cryptX/emu/ps4";
    extraConfig = ''
      if ( $server_addr != "${internal-ip}" ) {
        return 403;
      }
    '';
  };
}
