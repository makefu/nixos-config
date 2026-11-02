# Shared instantiation of the cert-relay module for the euer domain.
# Imported by both the relay server (gum) and every relay client host, so
# both sides agree on names and paths (NixOS dedupes module imports by file
# path, like 2configs/wireguard/euer/omo-ipfs-netns.nix).
{
  makefu.cert-relay.euer = {
    domain = "euer.syntax-fehler.de"; # cert covers *.${domain}
    certName = "euer-syntax-fehler-wildcard"; # security.acme.certs key — no '*' (assertion)
    # Manual step 4: paste the public half of the cert-relay@gum keypair
    # here after `ssh-keygen -t ed25519 -C cert-relay@gum`.
    pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQIpzJ4woRapTh92sue62YxNxaGX3A05OrKN4AG5S3J cert-relay@gum";
  };
}
