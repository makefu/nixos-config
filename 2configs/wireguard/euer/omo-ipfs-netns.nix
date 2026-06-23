# Thin wrapper around ./container-netns.nix pinning the netns/interface
# names + peer for omo's shared "ipfs" netns. Imported by every container
# that wants to live in that netns (currently kubo + radicle) — NixOS
# module dedup ensures the netns + wg services are only declared once.
import ./container-netns.nix {
  netns = "ipfs";
  ifname = "ipfs-wg";
  peerName = "omo-ipfs";
}
