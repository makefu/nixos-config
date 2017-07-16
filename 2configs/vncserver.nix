{config,lib,pkgs, ...}:
with lib;
let
  pwfile = (toString <secrets>)+ "/vnc-password"; # create with `vncpasswd`
  pwtmp = "/tmp/vnc-password";
  user = config.makefu.gui.user;
  vnc_port = 5900;
  web_port = 6080;
in {
  networking.firewall.allowedTCPPorts = [ 80 vnc_port web_port ];
  systemd.services = {
    # TODO: terminal-server without a real gui and virtual display manager
    terminal-server = {
      description = "VNC Terminal Server";
      after = [ "display-manager.service"  "graphical.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = user;
        Restart = "always";
        ExecStartPre = pkgs.writeDash "terminal-pre" ''
          sleep 5
          install -m0700 -o ${user} ${pwfile} ${pwtmp}
        '';
        ExecStart = "${pkgs.tigervnc}/bin/x0vncserver -display :0 -rfbport ${toString vnc_port} -passwordfile ${pwtmp}";
        PermissionsStartOnly = true;
        PrivateTmp = true;
      };
    };
    terminal-web = {
      description = "noVNC Web Server";
      after = [ "terminal-server.service"  "graphical.target" "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "nobody";
        ExecStart = "${pkgs.novnc}/bin/launch-novnc.sh --listen ${toString web_port} --vnc localhost:${toString vnc_port}";
				PrivateTmp = true;
      };
    };
  };
  services.nginx.enable = true;
  services.nginx.virtualHosts._.locations = {
    "/" = {
      root = "${pkgs.novnc}";
      index = "vnc_auto.html";
    };
    "/websockify" = {
      proxyPass = "http://127.0.0.1:6080/";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # VNC connection timeout
        proxy_read_timeout 61s;

        # Disable cache
        proxy_buffering off;
      '';
    };
  };
}
