let
  port = 7654;
in {
  services.tang = {
    enable = true;
    listenStream = [
      "192.168.111.11:${toString port}"
    ];
    ipAddressAllow = [
      "192.168.111.0/24"
    ];
  };

  networking.firewall.allowedTCPPorts = [ port ];

  state = [ "/var/lib/private/tang" ];
}
