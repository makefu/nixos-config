{ config, pkgs, lib, ...}:
let
  port = "8001"; # 
  db-dir = "/media/silent/db/yamtrack";
  internal-ip = "192.168.111.11";
  allowedTCPPorts = [ 8631 ];
in
  {
    # container requires access to signal-rest endpoint, not sure how to find the correct interface
  networking.firewall.interfaces."podman0" = { inherit allowedTCPPorts; };
  networking.firewall.interfaces."podman1" = { inherit allowedTCPPorts; };
  networking.firewall.interfaces."podman2" = { inherit allowedTCPPorts; };
  networking.firewall.interfaces."podman3" = { inherit allowedTCPPorts; };

  services.nginx.virtualHosts."track" = {
    serverAliases = [ "tube.lan" "mtube.lan" ];
    locations."/" = {
      proxyPass = "http://localhost:${port}";
      proxyWebsockets = true;
    };
  };
  sops.secrets.yamtrack = {};
  virtualisation.oci-containers.containers.yamtrack = {
    image = "ghcr.io/fuzzygrim/yamtrack:latest";
    ports = [ "${port}:8000" ];
    volumes = [
      "${db-dir}:/yamtrack/db"
  ];
  environmentFiles = [
      config.sops.secrets.yamtrack.path # SECRET=
  ];
    environment = {
        TZ=config.time.timeZone;
        REDIS_URL = "redis://redis:6379";
        # DEBUG= "True";
        REGISTRATION = "False";
      #PUBLIC_HOST_URL = "tube.lan";
      #PUBLIC_HOST_AUDIO_URL = "mtube.lan";
  };
  dependsOn = [
      "yamtrack-redis"
  ];
    extraOptions = [
      "--network-alias=yamtrack"
      "--network=yamtrack_default"
    ];
    #user = "metube";
};
  systemd.services."podman-yamtrack" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-yamtrack_default.service"
    ];
    requires = [
      "podman-network-yamtrack_default.service"
    ];
    partOf = [
      "podman-compose-yamtrack-root.target"
    ];
    wantedBy = [
      "podman-compose-yamtrack-root.target"
    ];
};
  virtualisation.oci-containers.containers."yamtrack-redis" = {
    image = "redis:7-alpine";
    volumes = [
      "yamtrack_redis_data:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=yamtrack_default"
    ];
  };
  systemd.services."podman-yamtrack-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-yamtrack_default.service"
    ];
    requires = [
      "podman-network-yamtrack_default.service"
    ];
    partOf = [
      "podman-compose-yamtrack-root.target"
    ];
    wantedBy = [
      "podman-compose-yamtrack-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-yamtrack_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f yamtrack_default";
    };
    script = ''
      podman network inspect yamtrack_default || podman network create yamtrack_default
    '';
    partOf = [ "podman-compose-yamtrack-root.target" ];
    wantedBy = [ "podman-compose-yamtrack-root.target" ];
  };
  systemd.tmpfiles.settings.yamtrack."${db-dir}"."d" = {
      mode = "777";
      user = "1000";
      group = "1000";
  };
}
