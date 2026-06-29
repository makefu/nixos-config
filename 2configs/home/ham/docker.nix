{ config, pkgs, lib, ... }:
let
  confdir = "/media/silent/db/hass";
  # Host networking shares the host netns, so podman's --dns is rejected and the
  # container would otherwise inherit the host's local stub resolver
  # (127.0.0.53). Pin the LAN resolver explicitly via a mounted resolv.conf.
  resolvConf = pkgs.writeText "hass-resolv.conf" ''
    nameserver 192.168.111.1
  '';
in {
  imports = [ 
    ./nginx.nix
    ./mqtt.nix
    ./signal-rest
    ./signal-rest/service.nix
  ];

  networking.firewall.allowedTCPPorts = [ 8123 ];
  state = [ "/var/lib/hass/known_devices.yaml" ];
  virtualisation.oci-containers.containers.hass = {
    image = "homeassistant/home-assistant:latest";
    environment = {
      TZ = "Europe/Berlin";
      UMASK = "007";
    };
    # Host networking: nginx reaches HA on localhost:8123, so the reverse-proxy
    # peer is 127.0.0.1 (already in trusted_proxies) — no bridge gateway in the
    # X-Forwarded-For path. Published ports are incompatible with --network=host.
    extraOptions = [
      "--network=host"
      # Required for habluetooth adapter recovery and aiodhcpwatcher
      # passive DHCP discovery; without these, the integrations log
      # "Missing NET_ADMIN/NET_RAW capabilities" / "Operation not
      # permitted" on every restart.

      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
    ];
    volumes = [
      "${confdir}:/config"
      # Pin LAN DNS (host net cannot use podman --dns) and let the container
      # resolve local names from the host's /etc/hosts.
      "${resolvConf}:/etc/resolv.conf:ro"
      "/etc/hosts:/etc/hosts:ro"
      #"/data/music:/config/media"
    ];
  };
  systemd.tmpfiles.rules = [
    #"f ${confdir}/docker-run 0770 kiosk kiosk - -"
    "d ${confdir} 0770 kiosk kiosk - -"
  ];
}
