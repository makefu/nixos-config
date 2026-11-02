# Relay receive side for the euer domain (runs on each target host).
{
  imports = [ ./euer.nix ];
  makefu.cert-relay.euer.client.enable = true;
}
