{ pkgs, lib, ... }:

with lib;
let
  name = "bgt_cyberwar_hidden_service";
  sec = (toString <secrets>) + "/";
  secdir = sec + name;
  srvdir = "/var/lib/tor/onion/";
  basedir = srvdir + name;
  hn = builtins.readFile (secdir + "/hostname");
in
{
  systemd.services.prepare-hidden-service = {
    wantedBy = [ "local-fs.target" ];
    before = [ "tor.service" ];
    serviceConfig = {
      ExecStart = pkgs.writeScript "prepare-euer-blog-service" ''
        #!/bin/sh
        set -euf
        if ! test -d "${basedir}" ;then
          mkdir -p "${srvdir}"
          cp -r "${secdir}" "${srvdir}"
          chown -R tor:tor "${srvdir}"
          chmod -R 700 "${basedir}"
        else
          echo "not overwriting ${basedir}"
        fi
      '';
      Type = "oneshot";
      RemainAfterExit = "yes";
      TimeoutSec = "0";
    };
  };
  services.nginx.virtualHosts."${hn}".locations."/" = {
    proxyPass = "https://blog.binaergewitter.de";
    extraConfig = ''
        proxy_set_header  Host blog.binaergewitter.de;
        proxy_ssl_server_name on;
    '';
  };
  services.tor = {
    enable = true;
    hiddenServices."${name}".map = [
     { port = 80; }
     # { port = 443; toHost = "blog.binaergewitter.de"; }
    ];
  };
}
