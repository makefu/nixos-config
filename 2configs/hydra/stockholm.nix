# iterative:
# $ hydra-create-user krebs --password derp --role admin
# curl 'http://hydra.wbob.r/project/.new' -X PUT -H 'Host: hydra.wbob.r' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Cookie: redirect_to=%252F; hydra_session=abcdefghijklmnopqrstuvwxyz' -H 'Connection: keep-alive' --data 'enabled=on&visible=on&name=stockholm&displayname=Stockholm&description=make+all+systems+into+1systems&homepage=https%3A%2F%2Fkrebsco.de&owner=krebs&declfile=spec.json&decltype=git&declvalue=http%3A%2F%2Fcgit.euer.krebsco.de%2Fhydra-stockholm'

{

  # TODO postgres backup

  services.hydra = {
    enable = true;
    hydraURL = "http://hydra.wbob.r"; # externally visible URL
    notificationSender = "hydra@wbob.r";
    # you will probably also want, otherwise *everything* will be built from scratch
    useSubstitutes = true;
    port = 3030;
    buildMachinesFiles = [];
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nginx = {
    enable = true;
    virtualHosts."hydra.wbob.r" = {
      locations."/" =  {
        proxyPass = "http://localhost:3030/";
        extraConfig = ''
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
