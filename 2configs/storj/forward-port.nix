{
  networking.firewall.allowedTCPPorts = [ 28967 ];
  #networking.nat.forwardPorts = [
  #  { # storj
  #    destination = "10.243.0.89:28967";
  #    proto = "tcp";
  #    sourcePort = 28967;
  #  }
  #];
  services.nginx.appendConfig = ''
    stream {
      upstream storj {
          server omo.r:28967;
      }

      server {
          listen 28967;
          proxy_pass storj;
      }
  }
    '';
}
