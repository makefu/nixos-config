{ pkgs }:
pkgs.writeDashBin "generate-secrets" ''
  set -euf
  HOSTNAME="''${1?must provide hostname}"
  TMPDIR=$(${pkgs.coreutils}/bin/mktemp -d)
  PASSWORD=$(${pkgs.pwgen}/bin/pwgen 25 1)
  HASHED_PASSWORD=$(echo $PASSWORD | ${pkgs.hashPassword}/bin/hashPassword -s) > /dev/null

  ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f $TMPDIR/ssh.id_ed25519 -P "" -C "" >/dev/null
  ${pkgs.openssl}/bin/openssl genrsa -out $TMPDIR/retiolum.rsa_key.priv 4096 2>/dev/null > /dev/null
  ${pkgs.openssl}/bin/openssl rsa -in $TMPDIR/retiolum.rsa_key.priv -pubout -out $TMPDIR/retiolum.rsa_key.pub 2>/dev/null > /dev/null
  cat <<EOF > $TMPDIR/hashedPasswords.nix
  {
    root = "$HASHED_PASSWORD";
  }
  EOF

  cd $TMPDIR
  for x in *; do
    ${pkgs.coreutils}/bin/cat $x | secrets insert -m $HOSTNAME/$x > /dev/null
  done
  echo $PASSWORD | secrets insert -m $HOSTNAME/root > /dev/null

  cat <<EOF
    $HOSTNAME = {
      owner = config.krebs.users.makefu;
      nets = {
        retiolum = {
          ip4.addr = "10.243.0.changeme";
          ip6.addr = "42:0:0:0:0:0:0:changeme";
          aliases = [
            "$HOSTNAME.r"
          ];
          tinc.pubkey = ${"''"}
  $(cat $TMPDIR/retiolum.rsa_key.pub)
          ${"''"};
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "$(cat $TMPDIR/ssh.id_ed25519.pub)";
    };
  EOF

  rm -rf $TMPDIR
''

