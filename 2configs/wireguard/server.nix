{ config, ... }:
let
  ext-if = config.makefu.server.primary-itf;
in { # wireguard server

  # opkg install wireguard luci-proto-wireguard

  # TODO: networking.nat

  # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  # conf.all.proxy_arp =1
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.244.0.0/24 -o ${ext-if} -j MASQUERADE
    '';
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.244.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = (toString <secrets>) + "/wireguard.key";
    allowedIPsAsRoutes = true;
    peers = [
    {
      # x
      allowedIPs = [ "10.244.0.2/32" ];
      publicKey = "fe5smvKVy5GAn7EV4w4tav6mqIAKhGWQotm7dRuRt1g=";
    }
    {
      # vbob
      allowedIPs = [ "10.244.0.3/32" ];
      publicKey = "Lju7EsCu1OWXhkhdNR7c/uiN60nr0TUPHQ+s8ULPQTw=";
    }
    {
      # x-test
      allowedIPs = [ "10.244.0.4/32" ];
      publicKey = "vZ/AJpfDLJyU3DzvYeW70l4FNziVgSTumA89wGHG7XY=";
    }
    {
      # work-router
      persistentKeepalive = 25;
      allowedIPs = [ "10.244.0.5/32" ];
      publicKey = "QJMwwYu/92koCASbHnR/vqe/rN00EV6/o7BGwLockDw=";
    }
    {
      # workr
      persistentKeepalive = 25;
      allowedIPs = [ "10.244.0.6/32" ];
      publicKey = "OFhCF56BrV9tjqW1sxqXEKH/GdqamUT1SqZYSADl5GA=";
    }
    {
      # mobile
      allowedIPs = [ "10.244.0.7/32" ];
      publicKey = "Y6fOW2QDt0SsHT7hSVzzJYQVB3JI/txO4/FDB54Z52A=";
    }
    ];
  };
  # TODO: this issue is related to the router which connects to the host but is
  # unable to re-connect once restarted
}
