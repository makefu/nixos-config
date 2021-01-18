{ config, pkgs, lib, ... }:
let
  # If your Jitsi environment has authentication set up,
  # you MUST set JITSI_PRIVATE_MODE to "true" and
  # you MUST pass a SECRET_JITSI_KEY to generate the JWT secret
  jitsiPrivateMode = "false";

  secretJitsiKey = "";

  jitsiISS = "";

  workadventureSecretKey = "";

  jitsiURL = "meet.euer.krebsco.de";

  domain = "work.euer.krebsco.de";
  # domain will redirect to this map. (not play.${domain})
  defaultMap = "npeguin.github.io/office-map/map.json";

  apiURL = "api.${domain}";
  apiPort = 9002;

  frontURL = "play.${domain}";
  frontPort = 9004;

  pusherURL = "push.${domain}";
  pusherPort = 9005;

  uploaderURL = "ul.${domain}";
  uploaderPort = 9006;

  frontImage = "thecodingmachine/workadventure-front:develop";
  pusherImage = "thecodingmachine/workadventure-pusher:develop";
  apiImage = "thecodingmachine/workadventure-back:develop";
  uploaderImage = "thecodingmachine/workadventure-uploader:develop";

in {

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };

  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;

  systemd.services.workadventure-network = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.docker}/bin/docker network create --driver bridge workadventure ||:
    '';
    after = [ "docker" ];
    before = [
      "docker-workadventure-back.service"
      "docker-workadventure-pusher.service"
      "docker-workadventure-uploader.service"
      "docker-workadventure-website.service"
    ];
  };

  virtualisation.oci-containers.backend = "docker";

  services.nginx.virtualHosts."${domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      return = "301 $scheme://play.${domain}/_/global/${defaultMap}";
    };
  };

  virtualisation.oci-containers.containers.workadventure-front = {
    image = frontImage;
    environment = {
      API_URL = pusherURL;
      JITSI_PRIVATE_MODE = jitsiPrivateMode;
      JITSI_URL = jitsiURL;
      SECRET_JITSI_KEY = secretJitsiKey;
      UPLOADER_URL = uploaderURL;
    };
    ports = [ "127.0.0.1:${toString frontPort}:80" ];
    extraOptions = [ "--network=workadventure" ];
  };
  services.nginx.virtualHosts."${frontURL}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = { proxyPass = "http://127.0.0.1:${toString frontPort}"; };
  };

  virtualisation.oci-containers.containers.workadventure-pusher = {
    image = pusherImage;
    environment = {
      API_URL = "workadventure-back:50051";
      JITSI_ISS = jitsiISS;
      JITSI_URL = jitsiURL;
      SECRET_KEY = workadventureSecretKey;
    };
    ports = [ "127.0.0.1:${toString pusherPort}:8080" ];
    extraOptions = [ "--network=workadventure" ];
  };
  services.nginx.virtualHosts."${pusherURL}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString pusherPort}";
      proxyWebsockets = true;
    };
    locations."/room" = {
      proxyPass = "http://127.0.0.1:${toString pusherPort}";
      proxyWebsockets = true;
    };
  };

  virtualisation.oci-containers.containers.workadventure-back = {
    image = apiImage;
    environment = {
      #DEBUG = "*";
      JITSI_ISS = jitsiISS;
      JITSI_URL = jitsiURL;
      SECRET_KEY = workadventureSecretKey;
    };
    ports = [ "127.0.0.1:${toString apiPort}:8080" "50051" ];
    extraOptions = [ "--network=workadventure" ];
  };
  services.nginx.virtualHosts."${apiURL}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = { proxyPass = "http://127.0.0.1:${toString apiPort}"; };
  };

  virtualisation.oci-containers.containers.workadventure-uploader = {
    image = uploaderImage;
    ports = [ "127.0.0.1:${toString uploaderPort}:8080" ];
    extraOptions = [ "--network=workadventure" ];
  };
  services.nginx.virtualHosts."${uploaderURL}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString uploaderPort}";
      proxyWebsockets = true;
    };
  };

  systemd.services.docker-workadventure-front.serviceConfig = {
    StandardOutput = lib.mkForce "journal";
    StandardError = lib.mkForce "journal";
  };
  systemd.services.docker-workadventure-uploader.serviceConfig = {
    StandardOutput = lib.mkForce "journal";
    StandardError = lib.mkForce "journal";
  };
  systemd.services.docker-workadventure-pusher.serviceConfig = {
    StandardOutput = lib.mkForce "journal";
    StandardError = lib.mkForce "journal";
  };
  systemd.services.docker-workadventure-back.serviceConfig = {
    StandardOutput = lib.mkForce "journal";
    StandardError = lib.mkForce "journal";
  };
}
