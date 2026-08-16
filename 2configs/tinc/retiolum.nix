{ config, inputs, ... }:
# retiolum, the krebs tinc mesh. Peers, host files and the /etc/hosts entries
# for <host>.r / <host>.i all come straight from the kartei registry; the only
# per-machine input is the ed25519 private key.
let
  machine = config.clan.core.settings.machine.name;
in
{
  imports = [ inputs.kartei.nixosModules.retiolum ];

  networking.retiolum.ed25519PrivateKeyFile =
    config.sops.secrets."${machine}-retiolum.ed25519_key.priv".path;
}
