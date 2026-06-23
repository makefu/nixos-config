# Shared "container in its own wireguard netns" setup.
#
# Given a netns name, a wireguard interface name and the peer entry in
# `makefu.euer-wg.peers` (which carries the wg keys + addresses), this
# module materialises:
#   * a network namespace (`/run/netns/<netns>`)
#   * a wireguard interface that lives in that netns and tunnels to gum
#   * /etc/netns/<netns>/resolv.conf  (used both for `ip netns exec` and
#     bind-mounted at /etc/resolv.conf inside the systemd-nspawn container)
#   * the sops secret declaration for the peer's wireguard private key
#
# Design / leak model
# -------------------
#   * Containers using this netns get no other interface — they share the
#     netns via `--network-namespace-path=/run/netns/<netns>` and so have
#     no host veth, no bridge and no published port.
#   * The encrypted wg UDP socket lives in the host's main netns (we create
#     the wg device there and only move the plaintext side into the netns),
#     so it follows omo's normal default route to gum's IPv4 endpoint.
#     Pinning the endpoint to IPv4 also keeps the encrypted side off omo's
#     main `euer` v6-default-route tunnel and avoids a wg-over-wg loop.
#   * IPv4 reaches the internet via gum's masquerade. IPv6 is routed
#     end-to-end: the peer's publicV6 is announced by gum via NDP proxy on
#     its external interface, and the only v6 route inside the netns is
#     through wg.
#
# Consumers (see 2configs/ipfs/omo-container.nix, 2configs/radicle/omo-container.nix)
# pass the netns into `containers.<name>.extraFlags` and bind-mount
# /etc/netns/<netns>/resolv.conf at /etc/resolv.conf — systemd-nspawn does
# NOT do this on its own the way `ip netns exec` does.

{ netns, ifname, peerName }:
{ config, pkgs, lib, ... }:
let
  selfPeer = config.makefu.euer-wg.peers.${peerName};
  serverPeer = config.makefu.euer-wg.peers.gum;
  # match 2configs/wireguard/euer/client.nix for omo
  serverEndpoint = "142.132.189.140";
  port = config.makefu.euer-wg.port;

  keyPath = config.sops.secrets."${peerName}-euer-wg.key".path;
in {
  sops.secrets."${peerName}-euer-wg.key" = {};

  environment.etc."netns/${netns}/resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 9.9.9.9
  '';

  systemd.services."netns-${netns}" = {
    description = "Network namespace ${netns}";
    wantedBy = [ "multi-user.target" ];
    before = [ "wireguard-${ifname}.service" ];
    path = with pkgs; [ iproute2 gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "netns-${netns}-up" ''
        set -eu
        if ! ip netns list | grep -qx '${netns}'; then
          ip netns add '${netns}'
        fi
        ip -n '${netns}' link set lo up
      '';
      ExecStop = "${pkgs.iproute2}/bin/ip netns del '${netns}'";
    };
  };

  # Custom service rather than networking.wireguard.interfaces — that module
  # is networkd-backed on omo and networkd does not support
  # interfaceNamespace. Hand-rolling lets us keep everything else untouched.
  systemd.services."wireguard-${ifname}" = {
    description = "WireGuard tunnel ${ifname} (lives in ${netns} netns)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "netns-${netns}.service"
      "network-pre.target"
      "sops-install-secrets.service"
    ];
    requires = [ "netns-${netns}.service" ];
    partOf = [ "netns-${netns}.service" ];

    path = with pkgs; [ iproute2 wireguard-tools ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu

      # clean any leftover interface from a previous, half-failed run
      if ip link show '${ifname}' >/dev/null 2>&1; then
        ip link del dev '${ifname}'
      fi
      if ip -n '${netns}' link show '${ifname}' >/dev/null 2>&1; then
        ip -n '${netns}' link del dev '${ifname}'
      fi

      # Create the wg device in the host namespace so the encrypted UDP
      # socket lives there (and follows omo's normal default route to
      # gum's IPv4 endpoint), then hand the plaintext side off into the
      # netns. Pinning the endpoint to IPv4 is what guarantees the
      # encrypted side does not loop back through omo's main `euer`
      # tunnel (which has ipv6DefaultRoute=true).
      ip link add dev '${ifname}' type wireguard
      wg set '${ifname}' \
        private-key '${keyPath}' \
        peer '${serverPeer.publicKey}' \
          endpoint '${serverEndpoint}:${toString port}' \
          persistent-keepalive 25 \
          allowed-ips '172.27.70.0/24,0.0.0.0/0,fd42:e1e0::/64,${selfPeer.publicV6}/128,::/0'
      ip link set dev '${ifname}' netns '${netns}'

      ip -n '${netns}' addr add '${selfPeer.ipv4}/24'      dev '${ifname}'
      ip -n '${netns}' addr add '${selfPeer.ula}/64'       dev '${ifname}'
      ip -n '${netns}' addr add '${selfPeer.publicV6}/128' dev '${ifname}'
      ip -n '${netns}' link set dev '${ifname}' up

      # IPv4: default route through the tunnel (NATed by gum).
      ip -n '${netns}' route add 172.27.70.0/24 dev '${ifname}' 2>/dev/null || echo "route to 172.27.70.0 already exists"
      ip -n '${netns}' route add default        dev '${ifname}'
      # IPv6: default route through the tunnel. gum has us in its NDP
      # proxy list for ${selfPeer.publicV6}, so packets back to us are
      # delivered. There is no other v6 route in this netns, so any v6
      # destination is forced through wg.
      ip -n '${netns}' -6 route add fd42:e1e0::/64 dev '${ifname}'
      ip -n '${netns}' -6 route add default        dev '${ifname}'
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip -n '${netns}' link del dev '${ifname}' || true
    '';
  };
}
