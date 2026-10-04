{
  config,
  inputs,
  pkgs, 
  lib,
  ...
}:
# retiolum, the krebs tinc mesh. Peers, host files and the /etc/hosts entries
# for <host>.r / <host>.i all come straight from the kartei registry; the only
# per-machine input is the ed25519 private key.
let
  machine = config.clan.core.settings.machine.name;
in
{
  imports = [ inputs.kartei.nixosModules.retiolum ];

  # networking.retiolum.package = pkgs.tinc_pre;
  networking.retiolum.ed25519PrivateKeyFile =
    config.sops.secrets."${machine}-retiolum.ed25519_key.priv".path;

  services.tincr.networks.retiolum.connectTo = lib.mkForce [
    "eva"
    "gum"
    "neoprism"
  ];
  networking.firewall.allowedTCPPorts = [655 ];
  networking.firewall.allowedUDPPorts = [655 ];

  # tincr picks the SPTPS cipher/kex for a peer from hosts/<peer> and falls
  # back to the *server* config when the peer file says nothing. It also
  # merges hosts/<myself> into that server config (C tinc parity), so the
  # `SPTPSCipher = aes-256-gcm` / `SPTPSKex = x25519-mlkem768` lines kartei
  # writes into our own host file to advertise what we support silently
  # become the fallback for every peer as well. Peers that advertise nothing
  # — every C tinc node, e.g. hotdog, styx, fatteh — then get offered a
  # 1249-byte ML-KEM kex they answer classically, and the handshake dies with
  # `BadKex` forever: gum could not reach hotdog.r at all while the node
  # showed up as reachable in the routing graph.
  #
  # Pin the fallback back to the wire-compatible defaults. `-o` is parsed as
  # Source::Cmdline and outranks every config file, and per-peer opt-in is
  # unaffected because that is read from hosts/<peer>, not from here.
  # Peers that are permanently down (nardole, …) are retried every few seconds
  # and each attempt logs three INFO lines, which drowns everything else in the
  # journal. Drop the retry churn only — handshake failures, "Connection with X
  # activated" and everything at warning or above still show up.
  systemd.services."tincr-retiolum".serviceConfig.LogFilterPatterns = [
    "~\\[INFO .*(Autoconnecting to|Trying to connect to|Closing connection with)"
  ];

}
