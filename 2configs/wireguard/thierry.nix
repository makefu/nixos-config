{ lib, ... }:
{
  networking.wireguard.interfaces.thierry-wg = {
    ips = [ "172.27.66.10/24" ]; # TODO: not dnyamic
    privateKeyFile = (toString <secrets>) + "/wg-thierry.key";
    allowedIPsAsRoutes = true;
    # explicit route via eth0 to gum
    peers = [
    {
      endpoint = "thierryhome.duckdns.org:51820";
      allowedIPs = [ "172.27.66.0/24" ];
      publicKey = "filYuG/xbb2YW8WT0xT26rzeZ/ZiM6NLnbxbsCR9rS0=";
      persistentKeepalive = 25;
    }
    #{
    #  allowedIPs = [ "172.27.66.3/32" ];
    #  publicKey = "cDIf14LH4qleXNo889lS2ATIqDx9r//JNCkhHlHgc1Q=";
    #}
  ];
  };
}
