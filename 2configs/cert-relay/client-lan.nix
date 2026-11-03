# Relay receive side for the LAN domain (runs on each target host).
{
  imports = [ ./lan.nix ];
  makefu.cert-relay.lan.client.enable = true;
}
