{config,lib,pkgs, ...}:
with lib;
let
  pwfile = (toString <secrets>)+ "/vnc-password"; # create with `vncpasswd`
  pwtmp = "/tmp/vnc-password";
  # nixos-unstable tigervnc is currently broken :\
  package = (import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-17.03.tar.gz) {}).pkgs.tigervnc;
  User = "makefu";
  port = 5900;
in {
	networking.firewall.allowedTCPPorts = [ port ];
	networking.firewall.allowedUDPPorts = [ port ];

	systemd.services."terminal-server" = {
    description = "Terminal Server";
    after = [ "display-manager.service" ];
    wantedBy = [ "graphical.target" ];
		serviceConfig = {
      inherit User;
      ExecStartPre = pkgs.writeDash "terminal-pre" ''
 
        set -eufx
        install -m0700 -o ${User} ${pwfile} ${pwtmp}
      '';
			ExecStart = "${package}/bin/x0vncserver -display :0 -rfbport ${toString port} -passwordfile ${pwtmp}";
      PermissionsStartOnly = true;
      PrivateTmp = true;
		};
	};
}
