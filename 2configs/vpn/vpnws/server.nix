{pkgs, options, ... }:
let
  pkg = pkgs.vpn-ws;
  uid = "nginx";
  gid = "nginx";
  ip = "${pkgs.iproute}/bin/ip";
  socket = "/run/vpn.sock";
  htpasswd = (toString <secrets>) + "/vpn-ws-auth";
  nginx-prepared-secrets = "/var/spool/nginx/vpn-ws-auth";
in {
  systemd.services.vpn-ws-auth-prepare = {
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];
    script = "install -m700 -o${uid} -g${gid} ${htpasswd} ${nginx-prepared-secrets}";
  };
  services.nginx.virtualHosts."euer.krebsco.de".locations."/vpn" = {
    extraConfig = ''
      auth_basic "please stand by...";
      auth_basic_user_file ${nginx-prepared-secrets};
      uwsgi_pass   unix:${socket};
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
      ExecStart = "${pkg}/bin/vpn-ws --uid ${uid} --gid ${gid} --tuntap vpnws ${socket}";
    };
  };
}
