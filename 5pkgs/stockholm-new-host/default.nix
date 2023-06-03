{ pkgs }:
pkgs.writers.writeDashBin "sthockholm-new-host" ''
  set -eu
  PATH=${lib.makePathBin with pkgs;[ mkpasswd pwqgen sshd coreutils openssh tinc_pre pass ]}:$PATH
  HOSTNAME=$1
  STOCKHOLM=~/stockholm
  KARTEI=$STOCKHOLM/kartei/makefu
  export PASSWORD_STORE_DIR=$HOME/.secrets-pass
  TMPDIR=$(mktemp -d)

  PASSWORD=$(pwqgen)
  HASHED_PASSWORD=$(echo $PASSWORD | mkpasswd -m sha-512 -s)

  cd "$TMPDIR"
  cat <<EOF > hashedPasswords.nix
  {
    root = "$HASHED_PASSWORD";
  }
  EOF

  tinc --config "$PWD" generate-keys 4096
  mv ed25519_key.priv retiolum.ed25519_key.priv
  mv rsa_key.priv retiolum.rsa_key.priv
  mv ed25519_key.pub retiolum.ed25519_key.pub
  mv rsa_key.pub retiolum.rsa_key.pub

  ssh-keygen -t ed25519 -f ssh_host_ed25519_key -P "" 
  ssh-keygen -t rsa -f ssh_host_rsa_key -P ""

  wg genkey > wireguard.key
  wg pubkey < wireguard.key > wireguard.pub

  for i in *;do
    cat "$i" | pass insert -m "$HOSTNAME/$i"
  done

  cp retiolum.ed25519_key.pub "$KARTEI/retiolum/$HOSTNAME_ed25519.pub"
  cp retiolum.rsa_key.pub "$KARTEI/retiolum/$HOSTNAME.pub"
  cp ssh_host_ed25519_key.pub "$KARTEI/sshd/$HOSTNAME.pub"
  echo "$PASSWORD" | pass insert -m "$HOSTNAME/root"


  cat <<EOF
  # add to $KARTEI/default.nix
  # then git add $KARTEI && git commit -m "ma $HOSTNAME.r: add to kartei"
  $HOSTNAME = {
    nets.retiolum.ipv4.addr = "10.243.12.XXX";
  };
  EOF
''
