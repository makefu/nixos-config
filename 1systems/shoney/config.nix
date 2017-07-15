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
    <stockholm/makefu>
    <stockholm/makefu/2configs/save-diskspace.nix>
    <stockholm/makefu/2configs/hw/CAC.nix>
    <stockholm/makefu/2configs/fs/CAC-CentOS-7-64bit.nix>
    <stockholm/makefu/2configs/tinc/retiolum.nix>
    <stockholm/makefu/2configs/torrent.nix>
  ];


  krebs = {
    enable = true;
    build.host = config.krebs.hosts.shoney;
    tinc_graphs = {
      enable = true;
      network = "siem";
      hostsPath = "/etc/tinc/siem/hosts";
      nginx = {
        enable = true;
        # TODO: remove hard-coded hostname
        anonymous-domain = "localhost.localdomain";
        anonymous.extraConfig = "return 403;";
        complete = {
          serverAliases = [ "graph.siem" ];
          extraConfig = ''
            if ( $server_addr = "${ip}" ) {
              return 403;
            }
          '';
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
