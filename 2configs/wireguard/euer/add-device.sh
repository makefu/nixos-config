#!/usr/bin/env bash
# Manage external (non-NixOS) devices in the euer WireGuard network.
# Intended for smartphones, webcams, tablets, and similar devices that
# cannot run NixOS but need a WireGuard tunnel into the euer network.

set -euo pipefail
FLAKE_DIR=$(nix flake metadata --json | grep makefu  | jq -r .resolvedUrl | sed 's#git+file://##')
COMMON_NIX="$FLAKE_DIR/2configs/wireguard/euer/common.nix"

SERVER_PUBKEY="nGVKBqslGPW+H/t+FG6L5JGUVS2DwPOM/UP3b7BRtTM="
SERVER_ENDPOINT="142.132.189.140"
SERVER_PORT=51826
ULA_PREFIX="fd42:e1e0"
V6_PREFIX="2a01:4f8:1c17:5cdf"
V4_PREFIX="172.27.70"

die() { echo "error: $*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage: $0 <command> [args]

Manage external (non-NixOS) devices in the euer WireGuard network.

Commands:
  new  <device-name>   Add a new device to the network
  get  <device-name>   Print the WireGuard config to stdout
  qr   <device-name>   Show the WireGuard config as a QR code
  list                 List devices that have a stored wireguard config
  help                 Show this help message

Examples:
  $0 new mobilex
  $0 get mobilex
  $0 qr mobilex
  $0 list
EOF
}

max_hex() {
  local max=0 dec
  while read -r h; do
    dec=$((16#$h))
    (( dec > max )) && max=$dec
  done
  echo "$max"
}

secret_name() { echo "${1}-euer-wireguard-config"; }

cmd_get() {
  [[ $# -eq 1 ]] || die "usage: $0 get <device-name>"
  clan secrets get "$(secret_name "$1")"
}

cmd_qr() {
  [[ $# -eq 1 ]] || die "usage: $0 qr <device-name>"
  cmd_get "$1" | qrencode -t ansiutf8
}

cmd_new() {
  [[ $# -eq 1 ]] || die "usage: $0 new <device-name>"
  local device="$1"
  [[ "$device" =~ ^[a-z][a-z0-9_-]*$ ]] || die "device name must be lowercase alphanumeric (may contain - or _)"
  grep -qP "^\s+${device}\s*=" "$COMMON_NIX" && die "peer '$device' already exists in common.nix"

  # allocate next free addresses (IPv6 hex, IPv4 decimal)
  local next_ula next_v6 next_v4 device_ula device_v6 device_v4 privkey pubkey peer_line client_conf
  next_ula=$(printf '%x' $(( $(grep -oP 'ula\s*=\s*"fd42:e1e0::\K[0-9a-f]+' "$COMMON_NIX" | max_hex) + 1 )))
  next_v6=$(printf '%x' $(( $(grep -oP 'publicV6\s*=\s*"\$\{prefix\}::\K[0-9a-f]+' "$COMMON_NIX" | max_hex) + 1 )))
  next_v4=$(( $(grep -oP 'ipv4\s*=\s*"172\.27\.70\.\K[0-9]+' "$COMMON_NIX" | sort -n | tail -1) + 1 ))

  device_ula="${ULA_PREFIX}::${next_ula}"
  device_v6="${V6_PREFIX}::${next_v6}"
  device_v4="${V4_PREFIX}.${next_v4}"

  # generate keypair
  privkey="$(wg genkey)"
  pubkey="$(echo "$privkey" | wg pubkey)"

  # add peer to common.nix
  peer_line="    ${device} = { ula = \"${device_ula}\"; ipv4 = \"${device_v4}\"; publicKey = \"${pubkey}\"; publicV6 = \"\${prefix}::${next_v6}\"; };"
  sed -i "/^  };$/i\\${peer_line}" "$COMMON_NIX"

  # build client config
  client_conf="[Interface]
PrivateKey = ${privkey}
Address = ${device_ula}/64, ${device_v6}/128, ${device_v4}/24
DNS = fd42:e1e0::1, 172.27.70.1

[Peer]
PublicKey = ${SERVER_PUBKEY}
Endpoint = ${SERVER_ENDPOINT}:${SERVER_PORT}
AllowedIPs = fd42:e1e0::/64, ::/0, 172.27.70.0/24, 0.0.0.0/0"

  # store secrets
  echo "$privkey"      | clan secrets set "${device}-euer-wg.key"
  echo "$pubkey"       | clan secrets set "${device}-euer-wg.pub"
  echo "$client_conf"  | clan secrets set "$(secret_name "$device")"

  cat <<EOF

  Added '${device}' to euer network
  ──────────────────────────────────
  ULA address   ${device_ula}
  IPv4 address  ${device_v4}
  Public IPv6   ${device_v6}
  Public key    ${pubkey}

  Retrieve config:  $0 get ${device}
  QR code:          $0 qr ${device}

  Remember to rebuild gum so it picks up the new peer.

EOF
}

cmd_list() {
  clan secrets list | grep -- '-euer-wireguard-config$' | sed 's/-euer-wireguard-config$//' | while read -r device; do
    echo "$device"
  done
}

if ! test -e "$COMMON_NIX" ;then
  usage
  die "cannot find $COMMON_NIX, running within the nixos-config repository?"
fi

case "${1:-help}" in
  new)   shift; cmd_new "$@" ;;
  get)   shift; cmd_get "$@" ;;
  qr)    shift; cmd_qr "$@" ;;
  list)  cmd_list ;;
  help)  usage ;;
  *)     die "unknown command '$1' (see '$0 help')" ;;
esac
