let
  prefix = "2a01:4f8:1c17:5cdf"; # gum ipv6 prefixed network from hetzner
  omo = "fd42:e1e0::2";
in {

  makefu.euer-wg.peers = {
    gum = { ula = "fd42:e1e0::1"; ipv4 = "172.27.70.1"; publicKey = "nGVKBqslGPW+H/t+FG6L5JGUVS2DwPOM/UP3b7BRtTM="; };
    omo = { ula = omo; ipv4 = "172.27.70.2"; publicKey = "uo8r+EyDtF6YcVgtrDsyX9vnewMclnrEPjNS4w6fsTM="; publicV6 = "${prefix}::12"; };
    x   = { ula = "fd42:e1e0::3"; ipv4 = "172.27.70.3"; publicKey = "FRowaSBIxz3caOyND8HQOXhnvpKkvGbN4Ok0239w9As="; publicV6 = "${prefix}::13"; };
    mobilex = { ula = "fd42:e1e0::4"; ipv4 = "172.27.70.4"; publicKey = "400DDEJkFlFsnxAWSSpWVyFyI3El1ICQMCfYsFYRnnw="; publicV6 = "${prefix}::14"; };
    mobilecam = { ula = "fd42:e1e0::5"; ipv4 = "172.27.70.5"; publicKey = "aLNirEv5HBnPO+jG/Zuf/b8JXcX+gnFsVOtBlOATpV0="; publicV6 = "${prefix}::15"; };
    # virtual peer living inside the `ipfs` netns on omo; see
    # 2configs/ipfs/omo-container.nix. publicV6 is announced by gum via NDP
    # proxy on its external interface, so the container has a fully routed
    # IPv6 address even though the host has none of its own.
    "omo-ipfs" = { ula = "fd42:e1e0::6"; ipv4 = "172.27.70.6"; publicKey = "IOb06La58Ia5fThELp0Fsd2YGEDbWZK+8/nF9O8X414="; publicV6 = "${prefix}::16"; };
    x2 = { ula = "fd42:e1e0::7"; ipv4 = "172.27.70.7"; publicKey = "OLdzPl6U2dozwyxP5YGBJSao/nJrTRaHiVDqFBrUMFs="; publicV6 = "${prefix}::17"; };
  };
  networking.hosts = {
    "${omo}" = [ "track.euer" "keep.euer" "hass.euer" ];
  };
}
