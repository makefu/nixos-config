{ config, pkgs, ... }:
let
  out-itf = config.makefu.server.primary-itf;
  # generate via openvpn --genkey --secret static.key
  client-key = (toString <secrets>) + "/openvpn-laptop.key";
  # domain = "vpn.euer.krebsco.de";
  domain = "gum.krebsco.de";
  dev = "tun0";
  port = 1194;
  tcp-port = 3306;
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nat = {
    enable = true;
    externalInterface = out-itf;
    internalInterfaces  = [ dev ];
  };
  networking.firewall.trustedInterfaces = [ dev ];
  networking.firewall.allowedUDPPorts = [ port ];
  environment.systemPackages = [ pkgs.openvpn ];
  services.openvpn.servers.smartphone.config = ''
    #user nobody
    #group nobody

    dev ${dev}
    proto udp
    ifconfig 10.8.0.1 10.8.0.2
    secret ${client-key}
    port ${toString port}
    cipher AES-256-CBC
    comp-lzo

    keepalive 10 60
    ping-timer-rem
    persist-tun
    persist-key
  '';

  environment.etc."openvpn/smartphone-client.ovpn" = {
    text = ''
      client
      dev tun
      remote "${domain}"
      ifconfig 10.8.0.1 10.8.0.2
      port ${toString port}

      cipher AES-256-CBC
      comp-lzo
      keepalive 10 60
      resolv-retry infinite
      nobind
      persist-key
      persist-tun

      secret [inline]

    '';
    mode = "700";
  };
  system.activationScripts.openvpn-addkey = ''
    f="/etc/openvpn/smartphone-client.ovpn"
    if ! grep -q '<secret>' $f; then
      echo "appending secret key"
      echo "<secret>" >> $f
      cat ${client-key} >> $f
      echo "</secret>" >> $f
    fi
  '';
  #smartphone-tcp.config = ''
  #  user nobody
  #  group nobody

  #  dev ${dev}
  #  proto tcp
  #  ifconfig 10.8.0.1 10.8.0.3
  #  secret ${client-key}
  #  port tcp-port
  #  comp-lzo

  #  keepalive 10 60
  #  ping-timer-rem
  #  persist-tun
  #  persist-key
  #'';
  # TODO: forward via 443
  # stream {
  #
  #   map $ssl_preread_server_name $name {
  #       vpn1.app.com vpn1_backend;
  #       vpn2.app.com vpn2_backend;
  #       https.app.com https_backend;
  #   }
  #
  #   upstream vpn1_backend {
  #       server 10.0.0.3:443;
  #   }
  #
  #   upstream vpn2_backend {
  #       server 10.0.0.4:443;
  #   }
  #
  #   upstream https_backend {
  #       server 10.0.0.5:443;
  #
  #   server {
  #       listen 10.0.0.1:443;
  #       proxy_pass $name;
  #       ssl_preread on;
  #   }
  # }
}
