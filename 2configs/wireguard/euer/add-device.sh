#!/usr/bin/env bash
# Add an external (non-NixOS) device to the euer WireGuard network.
# Intended for smartphones, webcams, tablets, and similar devices that
# cannot run NixOS but need a WireGuard tunnel into the euer network.
#
# Usage: ./add-device.sh <device-name>
# Examples:
#   ./add-device.sh mobilex
#   ./add-device.sh webcam-garden

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
COMMON_NIX="$SCRIPT_DIR/common.nix"

SERVER_PUBKEY="nGVKBqslGPW+H/t+FG6L5JGUVS2DwPOM/UP3b7BRtTM="
SERVER_ENDPOINT="142.132.189.140"
SERVER_PORT=51826
ULA_PREFIX="fd42:e1e0"
V6_PREFIX="2a01:4f8:1c17:5cdf"

die() { echo "error: $*" >&2; exit 1; }

max_hex() {
  local max=0 dec
  while read -r h; do
    dec=$((16#$h))
    (( dec > max )) && max=$dec
  done
  echo $max
}

[[ $# -eq 1 ]] || die "usage: $0 <device-name>"
DEVICE="$1"
[[ "$DEVICE" =~ ^[a-z][a-z0-9_-]*$ ]] || die "device name must be lowercase alphanumeric (may contain - or _)"
grep -qP "^\s+${DEVICE}\s*=" "$COMMON_NIX" && die "peer '$DEVICE' already exists in common.nix"

# allocate next free addresses (IPv6 hex)
next_ula=$(printf '%x' $(( $(grep -oP 'ula\s*=\s*"fd42:e1e0::\K[0-9a-f]+' "$COMMON_NIX" | max_hex) + 1 )))
next_v6=$(printf '%x' $(( $(grep -oP 'publicV6\s*=\s*"\$\{prefix\}::\K[0-9a-f]+' "$COMMON_NIX" | max_hex) + 1 )))

DEVICE_ULA="${ULA_PREFIX}::${next_ula}"
DEVICE_V6="${V6_PREFIX}::${next_v6}"

# generate keypair
PRIVKEY="$(wg genkey)"
PUBKEY="$(echo "$PRIVKEY" | wg pubkey)"

# add peer to common.nix
PEER_LINE="    ${DEVICE} = { ula = \"${DEVICE_ULA}\"; publicKey = \"${PUBKEY}\"; publicV6 = \"\${prefix}::${next_v6}\"; };"
sed -i "/^  };$/i\\${PEER_LINE}" "$COMMON_NIX"

# build client config
CLIENT_CONF=$(cat <<EOF
[Interface]
PrivateKey = ${PRIVKEY}
Address = ${DEVICE_ULA}/64, ${DEVICE_V6}/128
DNS = fd42:e1e0::1

[Peer]
PublicKey = ${SERVER_PUBKEY}
Endpoint = ${SERVER_ENDPOINT}:${SERVER_PORT}
AllowedIPs = fd42:e1e0::/64, ::/0
PersistentKeepalive = 25
EOF
)

# store secrets
echo "$PRIVKEY"     | clan secrets set "${DEVICE}-euer-wg.key" --flake "$REPO_DIR"
echo "$PUBKEY"      | clan secrets set "${DEVICE}-euer-wg.pub" --flake "$REPO_DIR"
SECRET_NAME="${DEVICE}-euer-wireguard-config"
echo "$CLIENT_CONF" | clan secrets set "$SECRET_NAME" --flake "$REPO_DIR"

cat <<EOF

  Added '${DEVICE}' to euer network
  ──────────────────────────────────
  ULA address   ${DEVICE_ULA}
  Public IPv6   ${DEVICE_V6}
  Public key    ${PUBKEY}
  Config secret ${SECRET_NAME}

  Retrieve config:  clan secrets get ${SECRET_NAME}
  QR code:          clan secrets get ${SECRET_NAME} | qrencode -t ansiutf8

  Remember to rebuild gum so it picks up the new peer.

EOF
