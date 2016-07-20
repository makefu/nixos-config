{ config, pkgs, ... }:
let
  tinc-siem-ip = "10.8.10.1";

  ip     = "64.137.234.215";
  alt-ip = "64.137.234.210";    # honeydrive honeyd
  extra-ip1 = "64.137.234.114"; # floating tinc.siem
  extra-ip2 = "64.137.234.232"; # honeydrive
  gw = "64.137.234.1";
in {
  imports = [
    ../.
    ../2configs/save-diskspace.nix
    ../2configs/hw/CAC.nix
    ../2configs/fs/CAC-CentOS-7-64bit.nix
    ../2configs/tinc/retiolum.nix
  ];


  krebs = {
    enable = true;
    build.host = config.krebs.hosts.shoney;
    nginx.enable = true;
    tinc_graphs = {
      enable = true;
      network = "siem";
      hostsPath = "/etc/tinc/siem/hosts";
      nginx = {
        enable = true;
        # TODO: remove hard-coded hostname
        complete = {
          listen = [ "${tinc-siem-ip}:80" ];
          server-names = [ "graphs.siem" ];
        };
      };
    };
  };
  makefu.forward-journal = {
    enable = true;
    src = "10.8.10.1";
    dst = "10.8.10.6";
  };
  networking =  {
    interfaces.enp2s1.ip4 = [
      { address = ip; prefixLength = 24; }
      # { address = alt-ip; prefixLength = 24; }
    ];

    defaultGateway = gw;
    nameservers = [ "8.8.8.8" ];
    firewall = {
      trustedInterfaces = [ "tinc.siem" ];
      allowedUDPPorts = [ 655 1655 ];
      allowedTCPPorts = [ 655 1655 ];
    };
  };
}
