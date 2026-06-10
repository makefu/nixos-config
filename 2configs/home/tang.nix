let
  port = 7654;
in {
  services.tang = {
    enable = true;
    listenStream = [
      (toString port)
    ];
    ipAddressAllow = [
      "0.0.0.0"
      "::/0"
    ];
  };

  networking.firewall.allowedTCPPorts = [ port ];

  state = [ "/var/lib/private/tang" ];
}
