let
  prefix = "2a01:4f8:1c17:5cdf"; # gum ipv6 prefixed network from hetzner
  omo = "fd42:e1e0::2";
in {

  makefu.euer-wg.peers = {
    gum =        { ula = "fd42:e1e0::1"; ipv4 = "172.27.70.1"; publicKey = "nGVKBqslGPW+H/t+FG6L5JGUVS2DwPOM/UP3b7BRtTM="; };
    omo =        { ula = "fd42:e1e0::2"; ipv4 = "172.27.70.2"; publicKey = "uo8r+EyDtF6YcVgtrDsyX9vnewMclnrEPjNS4w6fsTM="; publicV6 = "${prefix}::12"; };
    x   =        { ula = "fd42:e1e0::3"; ipv4 = "172.27.70.3"; publicKey = "FRowaSBIxz3caOyND8HQOXhnvpKkvGbN4Ok0239w9As="; publicV6 = "${prefix}::13"; };
    mobilex =    { ula = "fd42:e1e0::4"; ipv4 = "172.27.70.4"; publicKey = "400DDEJkFlFsnxAWSSpWVyFyI3El1ICQMCfYsFYRnnw="; publicV6 = "${prefix}::14"; };
    mobilecam =  { ula = "fd42:e1e0::5"; ipv4 = "172.27.70.5"; publicKey = "aLNirEv5HBnPO+jG/Zuf/b8JXcX+gnFsVOtBlOATpV0="; publicV6 = "${prefix}::15"; };
    # virtual peer living inside the `ipfs` netns on omo; see
    # 2configs/ipfs/omo-container.nix. publicV6 is announced by gum via NDP
    # proxy on its external interface, so the container has a fully routed
    # IPv6 address even though the host has none of its own.
    # omo-ipfs netns hosts kubo (no TCP exposure — uses QUIC), radicle-node
    # p2p (TCP 8776) + nginx serving radicle-explorer / seed HTTP API (TCP 80;
    # httpd itself stays on loopback 8081, 8080 is kubo's IPFS gateway) and
    # rtorrent (BitTorrent peer port 51412). flood's web UI is intentionally
    # NOT listed here — it stays internal-only on the ULA. See
    # 2configs/{ipfs,radicle,torrent}/omo-container.nix.
    "omo-ipfs" = { ula = "fd42:e1e0::6"; ipv4 = "172.27.70.6"; publicKey = "IOb06La58Ia5fThELp0Fsd2YGEDbWZK+8/nF9O8X414="; publicV6 = "${prefix}::16"; openTCPPorts = [ 8776 80 443 51412 ]; };
    x2 =         { ula = "fd42:e1e0::7"; ipv4 = "172.27.70.7"; publicKey = "Wkzb7YSw8Yz0hosSBg63JWopsrqR6vZtkvWkvbzerw4="; publicV6 = "${prefix}::17"; };
    # Home Assistant runs in its own br0 NixOS container on omo
    # (2configs/home/ham/container.nix) and joins euer as a first-class peer so
    # hass.euer resolves to the container itself instead of omo's host. Internal
    # only: no publicV6 (not exposed to the internet), reached over the ULA.
    # The module auto-maps hass.euer -> this ula for every euer member, which is
    # why the manual hass.euer entry was dropped from networking.hosts below.
    hass =       { ula = "fd42:e1e0::8"; ipv4 = "172.27.70.8"; publicKey = "U6QSYt95mAvb9CNxVYBHFBj5LOPdpoaK9nSbDOZ2hQw="; };
    tab8 = { ula = "fd42:e1e0::9"; ipv4 = "172.27.70.9"; publicKey = "rQJuTf5AU7/4ncfSe1AQgxzB4TlAxJX5mu1Gvp7ajyM="; publicV6 = "${prefix}::18"; };
  };
  networking.hosts = {
    "${omo}" = [
      "track.euer"
      "keep.euer"
      "graph.euer"
      "torrent.omo.euer"
      "alert.euer"
      "karma.euer"
      "prometheus.euer"
      "movies.euer"
      "jelly.euer"
      "abook.euer"
      "book.euer"
      "search.euer"
    ];
  };
}
