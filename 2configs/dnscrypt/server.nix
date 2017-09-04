{ config, ... }:
let
    # TODO: dataDir is currently not provided by upstream
    # data = config.services.dnscrypt-wrapper.dataDir;
    data = "/var/lib/dnscrypt-wrapper";
    sec = toString <secrets>;
    port = 15251;
    user = "dnscrypt-wrapper";
in {
  services.dnscrypt-wrapper = {
    enable = true;
    address = "0.0.0.0";
    upstream.address = "8.8.8.8";
    providerName = "2.dnscrypt-cert.euer.krebsco.de";
    inherit port;
  };
  networking.firewall.allowedUDPPorts = [ port ];
  systemd.services.prepare-dnscrypt-wrapper-keys = {
    wantedBy = [ "dnscrypt-wrapper.service" ];
    before = [ "dnscrypt-wrapper.service" ];
    script = ''
      install -m700 -o ${user} -v ${sec}/dnscrypt-public.key ${data}/public.key
      install -m700 -o ${user} -v ${sec}/dnscrypt-secret.key ${data}/secret.key
    '';
  };
}
