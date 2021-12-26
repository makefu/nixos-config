{ config, pkgs, lib, ... }:
let
  backend_port = 30005;
  #host = config.networking.hostName;
  ident = 998;
  user = "${toString ident}:${toString ident}";
  #backend_host = "tonie.lan";
  backend_host = "tonie.omo.r";
  frontend_port = 30006;
  homedir = "/var/lib/tonies";
  albumdir = "${homedir}/albumart/";
  vueconfig = pkgs.writeText "vueconfig" ''
    module.exports = {
      devServer: {
        disableHostCheck: true
      },
    }
  '';
  audiobookdir = "/media/cryptX/music/kinder_hoerspiele";
  #  TONIE_AUDIO_MATCH_USER = username;
  #  TONIE_AUDIO_MATCH_PASS = password;
  tonie-env = toString <secrets/tonie.env>;
in
  {
    systemd.tmpfiles.rules = [
      "d ${albumdir} 1750 toniebox toniebox -"
    ];
  networking.firewall.allowedTCPPorts = [ frontend_port backend_port ];
  virtualisation.oci-containers.containers.toniebox-front = {
    image = "makefoo/toniebox-audio-match_front:1.0.0";
    inherit user;
    environment = {
      VUE_APP_BACKEND_SCHEME = "http";
      VUE_APP_BACKEND_HOST = backend_host;
      #VUE_APP_BACKEND_PORT = toString backend_port;
      VUE_APP_BACKEND_PORT = "80";
    };
    ports = [ "${toString frontend_port}:8080" ];
    volumes = [
      "${albumdir}:/frontend/public/assets/covers"
      "${vueconfig}:/frontend/vue.config.js"
    ];
  };

  users.users.toniebox = {
    isSystemUser = true;
    uid = ident;
    home = homedir;
    createHome = true;
    group = "toniebox";
  };
  users.groups.toniebox.gid = ident;

  virtualisation.oci-containers.containers.toniebox-back = {
    image = "makefoo/toniebox-audio-match_back:1.0.0";
    inherit user;
    environmentFiles = [ tonie-env ];
    ports = [ "${toString backend_port}:5000" ];
    volumes = [
      "${albumdir}:/backend/assets/covers"
      "${audiobookdir}:/backend/assets/audiobooks"
    ];
  };
  services.nginx.virtualHosts."tonie" = {
    serverAliases = [ "tonie.lan" "tonie.omo.r" backend_host ];
    locations."/".proxyPass = "http://localhost:${toString frontend_port}";
    locations."/upload".proxyPass = "http://localhost:${toString backend_port}";
    locations."/creativetonies".proxyPass = "http://localhost:${toString backend_port}";
    locations."/audiobooks".proxyPass = "http://localhost:${toString backend_port}";
  };
}
