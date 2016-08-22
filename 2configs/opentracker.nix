{pkgs, ...}:

let
  daemon-port = 16969;
  cfgfile = pkgs.writeText "opentracker-cfg" ''
  '';
in {
  # Opentracker does not support local IPs (10.0.0.0/8 )
  makefu.opentracker = {
    enable = true;
    args = "-p ${toString daemon-port} -P ${toString daemon-port}";
  };
  networking.firewall.allowedTCPPorts = [ daemon-port ];
  networking.firewall.allowedUDPPorts = [ daemon-port ];

}
