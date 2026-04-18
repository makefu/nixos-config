let
  prefix = "2a01:4f8:1c17:5cdf"; # gum ipv6 prefixed network from hetzner
in {
  makefu.euer-wg.peers = {
    gum = { ula = "fd42:e1e0::1"; ipv4 = "172.27.70.1"; publicKey = "nGVKBqslGPW+H/t+FG6L5JGUVS2DwPOM/UP3b7BRtTM="; };
    omo = { ula = "fd42:e1e0::2"; ipv4 = "172.27.70.2"; publicKey = "uo8r+EyDtF6YcVgtrDsyX9vnewMclnrEPjNS4w6fsTM="; publicV6 = "${prefix}::12"; };
    x   = { ula = "fd42:e1e0::3"; ipv4 = "172.27.70.3"; publicKey = "FRowaSBIxz3caOyND8HQOXhnvpKkvGbN4Ok0239w9As="; publicV6 = "${prefix}::13"; };
    mobilex = { ula = "fd42:e1e0::4"; ipv4 = "172.27.70.4"; publicKey = "400DDEJkFlFsnxAWSSpWVyFyI3El1ICQMCfYsFYRnnw="; publicV6 = "${prefix}::14"; };
    mobilecam = { ula = "fd42:e1e0::5"; ipv4 = "172.27.70.5"; publicKey = "aLNirEv5HBnPO+jG/Zuf/b8JXcX+gnFsVOtBlOATpV0="; publicV6 = "${prefix}::15"; };
  };
}
