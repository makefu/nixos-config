{ config, pkgs, lib, ... }:

# Rootless-ish IPFS (kubo) on omo:
#   * podman container; the kubo process inside runs as a non-root uid
#     (not the host root user).
#   * confined to a dedicated network namespace whose ONLY interface is a
#     dedicated wireguard tunnel to the euer server (gum). The container
#     therefore can reach the network only via that tunnel — if the tunnel
#     is down the container has no connectivity at all. There is no veth,
#     no bridge and no published port, so it cannot bypass the tunnel.
#   * IPv4 reaches the internet via gum's masquerade. IPv6 is routed
#     end-to-end: the container's publicV6 is announced by gum via NDP
#     proxy on the external interface, so the container has a real,
#     globally-routed IPv6 address.
#   * data lives at /media/cryptX/ipfs (decrypted at boot). The container
#     only starts after that mount is up.
#
# Leak model — the ONLY traffic from the container that ever leaves the
# wireguard tunnel is the *encrypted* UDP between the wg interface and
# gum's IPv4 endpoint (142.132.189.140:51826). That socket lives in the
# host's main netns, NOT in the ipfs netns; it is unreachable from inside
# the container. Everything else (IPv4, IPv6, DNS, ICMP, NDP) is sealed
# inside the ipfs netns and can only egress through ipfs-wg.
#
# The host's existing `euer` wireguard interface is left alone — it is
# managed by systemd-networkd and that backend does not support
# interfaceNamespace. We set the netns interface up directly with `wg(8)`
# / `ip(8)` instead.

let
  netns = "ipfs";
  ifname = "ipfs-wg";
  dataDir = "/media/cryptX/ipfs";

  # uid/gid used both for the in-container kubo process and the host-side
  # owner of the bind-mounted data directory. With rootful podman (the
  # virtualisation.oci-containers default) and `--user=UID:GID` these map
  # 1:1 to the host so /media/cryptX/ipfs is owned by this uid on disk.
  kuboUid = 5001;
  kuboGid = 5001;

  selfPeer = config.makefu.euer-wg.peers."omo-ipfs";
  serverPeer = config.makefu.euer-wg.peers.gum;
  # match 2configs/wireguard/euer/client.nix for omo
  serverEndpoint = "142.132.189.140";
  port = config.makefu.euer-wg.port;

  keyPath = config.sops.secrets."omo-ipfs-euer-wg.key".path;
in {

  sops.secrets."omo-ipfs-euer-wg.key" = {};

  users.users.kubo = {
    isSystemUser = true;
    group = "kubo";
    uid = kuboUid;
    description = "ipfs/kubo container process";
  };
  users.groups.kubo.gid = kuboGid;

  systemd.tmpfiles.settings."10-kubo-data" = {
    "${dataDir}".d = {
      user = "kubo";
      group = "kubo";
      mode = "0750";
    };
  };

  # 1) network namespace ------------------------------------------------------
  systemd.services."netns-${netns}" = {
    description = "Network namespace ${netns} (kubo)";
    wantedBy = [ "multi-user.target" ];
    before = [
      "wireguard-${ifname}.service"
      "podman-kubo.service"
    ];
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

  # `ip netns exec` bind-mounts /etc/netns/<ns>/resolv.conf over
  # /etc/resolv.conf for processes started inside the namespace.
  environment.etc."netns/${netns}/resolv.conf".text = ''
    nameserver fd42:e1e0::1
    nameserver 172.27.70.1
  '';

  # 2) wireguard tunnel inside the netns -------------------------------------
  # We avoid networking.wireguard.interfaces here because omo runs the
  # networkd-backed wireguard module and that backend does not support
  # interfaceNamespace. A small one-shot service is enough: the wg
  # interface is short-lived state, the key material lives in sops, and
  # the routing only needs to be set up once at start.
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
    before = [ "podman-kubo.service" ];

    path = with pkgs; [ iproute2 wireguard-tools ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    # allowed-ips covers all of v4 and v6 — anything the container tries
    # to send goes through gum, anything gum sends us is accepted.
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
      ip -n '${netns}' route add 172.27.70.0/24 dev '${ifname}'
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

  # 3) kubo container --------------------------------------------------------
  virtualisation.oci-containers.containers.kubo = {
    image = "ipfs/kubo:release";
    user = "${toString kuboUid}:${toString kuboGid}";
    volumes = [
      "${dataDir}:/data/ipfs:rw"
    ];
    environment = {
      IPFS_PATH = "/data/ipfs";
    };
    extraOptions = [
      # Join the pre-created namespace. The container has no other network
      # access of any kind (no host networking, no CNI, no published ports).
      "--network=ns:/run/netns/${netns}"
      # Drop capabilities the kubo process should never need; this also
      # prevents the container from reconfiguring routing inside the netns.
      "--cap-drop=NET_ADMIN"
      "--cap-drop=NET_RAW"
      "--cap-drop=SYS_ADMIN"
      "--security-opt=no-new-privileges"
    ];
  };

  # 4) ordering: wait for storage, netns and wg before kubo comes up ---------
  systemd.services."podman-kubo" = {
    after = [
      "media-cryptX.mount"
      "netns-${netns}.service"
      "wireguard-${ifname}.service"
    ];
    requires = [
      "media-cryptX.mount"
      "netns-${netns}.service"
      "wireguard-${ifname}.service"
    ];
    unitConfig.RequiresMountsFor = [ dataDir ];
  };
}
