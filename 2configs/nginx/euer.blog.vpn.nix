{pkgs, options, ... }:
let
  pkg = pkgs.vpn-ws;
  uid = "nginx";
  gid = "nginx";
  ip = "${pkgs.iproute}/bin/ip";
in {
  services.nginx.virtualHosts."euer.krebsco.de".locations."/vpn" = {
    # TODO client auth
    extraConfig = ''
      uwsgi_pass   unix:/run/vpn.sock;
      include      ${pkgs.nginx}/conf/uwsgi_params;
    '';
  };

  networking.interfaces.vpnws = {
    virtual = true;
    virtualType = "tap";
  };
  systemd.services.vpnws = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "always";
      PrivateTmp = true;
      ExecStartPre = pkgs.writeDash "vpnws-pre" ''
        ${ip} link set vpnws up
        ${ip} addr add 10.244.1.1/24 dev vpnws || :
      '';
      ExecStart = pkgs.writeDash "vpnws-start" ''
        ${pkg}/bin/vpn-ws --tuntap vpnws /run/vpn.sock
      '';
    };
  };
}
