{ config, lib, ... }:
# Host-level networking for omo. The physical interface name (enp2s0) and the
# networkd wait-online ignore list live in hw/omo/network.nix; this file owns
# the policy on top of it: the LAN bridge, firewall trust/ports and the
# primary-itf override that follows the bridge.
#
# br0 exists so the diyHue container (2configs/home/hue.nix) can put its veth on
# the LAN and pull its own DHCP lease. enp2s0 becomes a bridge port and the host
# IP migrates onto br0.
#
# WARNING: switching the bridge in on a live remote host can briefly drop
# connectivity while br0 comes up.
let
  primaryInterface = "enp2s0";
in
{
  systemd.network = {
    netdevs."20-br0".netdevConfig = {
      Name = "br0";
      Kind = "bridge";
      # Inherit enp2s0's physical MAC. Otherwise the bridge picks a random
      # derived MAC, the router's DHCP reservation for omo (192.168.111.11 =
      # omo.lan) no longer matches, and the host comes up on a stray lease with
      # omo.lan unreachable.
      MACAddress = "40:8d:5c:73:b0:7f";
    };

    networks = {
      # enp2s0 is now a plain bridge port: no address, do not gate boot on it.
      "30-enp2s0" = {
        matchConfig.Name = primaryInterface;
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
      };

      # br0 inherits the LAN role enp2s0 used to have (DHCP v4/v6). The DHCP
      # lease's DNS is not applied reliably on the bridge, so pin the LAN
      # resolver explicitly (192.168.111.1 = gateway/router) to keep name
      # resolution working on the host.
      "40-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCP = "yes";
          DNS = "192.168.111.1";
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  # The LAN-facing interface is br0 now; every consumer of primary-itf
  # (wiregrill/euer masquerade, nsupdate dyndns, samba bind, stats) must follow,
  # otherwise they'd reference the address-less bridge port. mkForce overrides
  # the plain assignment in hw/omo/network.nix.
  makefu.server.primary-itf = lib.mkForce "br0";

  networking.firewall = {
    trustedInterfaces = [ "br0" "docker0" ];
    # 80 -> nginx, 8123 -> Home Assistant (ham/docker.nix).
    allowedTCPPorts = [ 80 8123 ];
  };
}
