# Relay push side for the LAN domain (runs on gum).
{
  imports = [ ./lan.nix ];
  makefu.cert-relay.lan.server = {
    enable = true;
    targets = [ "omo.euer" ]; # resolvable via euer-wg hosts entries
  };
}
