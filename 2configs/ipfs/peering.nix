{
  # Persistent peers for kubo. The Peering subsystem keeps an unconditional
  # bitswap-capable connection to each listed peer (auto-reconnects on drop),
  # which is required when the only known provider of a CID is a single
  # long-lived node that does not consistently reprovide every leaf block to
  # the DHT.
  #
  # See https://github.com/ipfs/kubo/blob/master/docs/config.md#peering
  #
  # Concrete trigger: `ipfs pin add QmUcKX53...` (unreal-tournament-2004) on
  # omo stalled at ~575 kB because `ipfs routing findprovs` returned one
  # external provider (`12D3KooWDccB4dV...`, Hetzner) and bitswap never
  # dialed it on its own. A manual `ipfs swarm connect` to that peer
  # unblocked the fetch immediately. Pinning the peer here makes that
  # connection survive daemon restarts.
  services.kubo.settings.Peering.Peers = [
    {
      ID = "12D3KooWDccB4dVFt6uyfD5Yc3brwj4JLSztPeJpY3yg965iB5uT";
      Addrs = [
        "/ip4/95.217.192.59/udp/4001/quic-v1"
        "/ip6/2a01:4f9:4a:4f1a::2/udp/4001/quic-v1"
      ];
    }
  ];
}
