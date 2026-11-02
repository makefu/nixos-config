# Relay push side for the euer domain (runs on gum).
{
  imports = [ ./euer.nix ];
  makefu.cert-relay.euer.server = {
    enable = true;
    targets = [ "omo.euer" ]; # resolvable via euer-wg hosts entries
  };
}
