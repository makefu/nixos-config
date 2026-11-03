# Shared instantiation of the cert-relay module for the LAN domain.
# Imported by both the relay server (gum) and every relay client host, so
# both sides agree on names and paths (NixOS dedupes module imports by file
# path, like ./euer.nix).
#
# Public DNS: *.lan.syntax-fehler.de (A) -> 192.168.111.11 = omo's LAN lease,
# so LAN clients terminate TLS against the real LE cert directly on omo.
{
  makefu.cert-relay.lan = {
    domain = "lan.syntax-fehler.de"; # cert covers *.${domain}
    certName = "lan-syntax-fehler-wildcard"; # security.acme.certs key — no '*' (assertion)
    # Same zone owner as euer: syntax-fehler.de is not on netcup CloudDNS
    # (v1 API reports isDnsManaged:false) -> legacy session API.
    dnsProvider = "netcup";
    # public half of the cert-relay@gum push keypair
    # (private half in clan secret gum-cert-relay.key)
    pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQIpzJ4woRapTh92sue62YxNxaGX3A05OrKN4AG5S3J cert-relay@gum";
  };
}
