# Shared instantiation of the cert-relay module for the euer domain.
# Imported by both the relay server (gum) and every relay client host, so
# both sides agree on names and paths (NixOS dedupes module imports by file
# path, like 2configs/wireguard/euer/omo-ipfs-netns.nix).
{
  makefu.cert-relay.euer = {
    domain = "euer.syntax-fehler.de"; # cert covers *.${domain}
    certName = "euer-syntax-fehler-wildcard"; # security.acme.certs key — no '*' (assertion)
    # syntax-fehler.de is not on netcup CloudDNS yet (v1 API reports
    # isDnsManaged:false), so DNS-01 must use the legacy session API.
    # Flip back to "netcupv1" after a CloudDNS migration.
    dnsProvider = "netcup";
    # public half of the cert-relay@gum push keypair
    # (private half in clan secret gum-cert-relay.key)
    pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQIpzJ4woRapTh92sue62YxNxaGX3A05OrKN4AG5S3J cert-relay@gum";
  };
}
