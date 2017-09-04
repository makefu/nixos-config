{ config, ... }:
let
  customResolver = {
    # TODO: put this somewhere else
    address = config.krebs.hosts.gum.nets.internet.ip4.addr;
    port = 15251;
    name = "2.dnscrypt-cert.euer.krebsco.de";
    # dnscrypt-wrapper --show-provider-publickey --provider-publickey-file public.key
    key = "1AFC:E58D:F242:0FBB:9EE9:4E51:47F4:5373:D9AE:C2AB:DD96:8448:333D:5D79:272C:A44C";
  };
in {
  services.dnscrypt-proxy = {
    enable = true;
    inherit customResolver;
  };
  networking.extraResolvconfConf = ''
    name_servers='127.0.0.1'
  '';
}
