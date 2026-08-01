{ config, pkgs, lib, ... }:
# Home Assistant with its own LAN presence, mirroring the diyHue setup
# (2configs/home/hue.nix). Previously HA ran as a podman container sharing omo's
# host netns (--network=host on the host), so it lived on omo's IP/MAC and had
# to share :8123 behind omo's nginx. To give HA its own MAC + DHCP lease (a real
# device on the LAN, needed for clean mDNS/discovery and a stable router
# reservation independent of omo), it now runs inside a NixOS container whose
# veth is enslaved to the host bridge br0 (defined in machines/omo/networking.nix).
#
# The container keeps running the upstream homeassistant/home-assistant image via
# podman (nested inside the container) so the hand-managed config tree in
# /media/silent/db/hass — HACS, UI-added integrations, state — is preserved
# verbatim; only the network placement changes. nginx also runs inside the
# container so hass.lan resolves to the container's own IP and both
# http://<lan-ip>/ and http://<lan-ip>:8123 work; omo no longer proxies HA.
#
# Because HA leaves omo's netns, "localhost" services it used to reach on the
# host must be addressed over the LAN instead. In the HA config under
# /media/silent/db/hass (NOT managed by Nix) point at omo.lan:
#   - mqtt broker      localhost:1883  -> omo.lan:1883   (mosquitto, ./mqtt.nix)
#   - influxdb host     localhost       -> omo.lan
#   - signal-cli-rest   localhost:8631  -> omo.lan:8631  (./signal-rest)
# mosquitto already listens on all interfaces and br0 is a trusted firewall
# interface on omo, so no host-side change is required for those services.
let
  confdir = "/media/silent/db/hass";
  # Stable, locally-administered MAC. Pins the container veth => stable DHCP
  # lease / router reservation. Distinct from diyHue's 02:00:00:CA:FE:01.
  mac = "02:00:00:CA:FE:02";
in {
  imports = [
    ./mqtt.nix                 # mosquitto broker stays on the omo host
    ./signal-rest              # signal-cli-rest stays on the omo host
    ./signal-rest/service.nix
  ];

  # Config/state tree lives on omo's storage pool; bind it into the container.
  systemd.tmpfiles.rules = [
    "d ${confdir} 0770 kiosk kiosk - -"
  ];

  # euer wireguard private key for the hass peer. Decrypted on the omo host
  # (the container has no sops-nix) and bind-mounted into the container below.
  sops.secrets."hass-euer-wg.key" = {};

  containers.hass = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localMacAddress = mac;

    # Persist HA's config/state on the host FS (survives container rebuilds).
    bindMounts."${confdir}" = {
      hostPath = confdir;
      isReadOnly = false;
    };

    # euer wireguard key from the host's sops store (container has no sops-nix).
    bindMounts."/run/euer-wg.key" = {
      hostPath = config.sops.secrets."hass-euer-wg.key".path;
      isReadOnly = true;
    };

    # Nested podman needs to mount its overlay storage; fuse-overlayfs avoids the
    # native-overlayfs-in-nspawn limitations. Requires /dev/fuse + CAP_SYS_ADMIN.
    enableTun = true;
    # CAP_BPF (+ CAP_PERFMON) so crun can load the cgroup-v2 eBPF device filter;
    # since kernel 5.8 BPF_PROG_LOAD needs CAP_BPF, CAP_SYS_ADMIN no longer
    # suffices, otherwise crun dies with "bpf create: Operation not permitted".
    additionalCapabilities = [
      "CAP_SYS_ADMIN" "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_BPF" "CAP_PERFMON"
    ];
    allowedDevices = [
      { node = "/dev/fuse"; modifier = "rwm"; }
    ];

    config = { config, pkgs, lib, ... }:
      let
        # Host stub resolver (127.0.0.53) can't be reached from the podman
        # container's mount view reliably; pin the LAN router which also serves
        # the *.lan names HA needs (omo.lan, mqtt.lan, ...).
        resolvConf = pkgs.writeText "hass-resolv.conf" ''
          nameserver 192.168.111.1
        '';
      in {
        # Container runs its own networkd + resolved and gets DNS from DHCP, so
        # it must not inherit the host's /etc/resolv.conf (trips a
        # nixos-containers assertion otherwise).
        networking.useHostResolvConf = false;

        # DHCP on the bridged veth (host side vb-hass, container side eth0).
        systemd.network = {
          enable = true;
          networks."10-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig.DHCP = "yes";
          };
        };

        # Join the euer wireguard overlay as its own peer (hass, fd42:e1e0::8)
        # so hass.euer resolves straight to this container instead of omo's host.
        # Hub-and-spoke: the only peer is gum, which routes to the other euer
        # members. gum's pubkey/endpoint are duplicated from euer/common.nix
        # because the euer-wg module can't run in here (it hardcodes the sops key
        # path and defaults its hostname to clan's machine name, neither of which
        # exist inside the nspawn container). persistentKeepalive keeps the NAT
        # mapping open so gum can reach hass.euer inbound. Key comes from the
        # host sops store via the /run/euer-wg.key bind-mount above.
        networking.wireguard.interfaces.euer = {
          ips = [ "fd42:e1e0::8/64" "172.27.70.8/24" ];
          listenPort = 51826;
          privateKeyFile = "/run/euer-wg.key";
          peers = [{
            publicKey = "nGVKBqslGPW+H/t+FG6L5JGUVS2DwPOM/UP3b7BRtTM=";  # gum
            endpoint = "142.132.189.140:51826";
            allowedIPs = [ "fd42:e1e0::/64" "172.27.70.0/24" ];
            persistentKeepalive = 25;
          }];
        };

        virtualisation.podman.enable = true;
        virtualisation.oci-containers.backend = "podman";

        # Force fuse-overlayfs so podman's storage mounts work inside nspawn.
        virtualisation.containers.storage.settings = {
          storage = {
            driver = "overlay";
            options.overlay.mount_program =
              "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs";
          };
        };

        virtualisation.oci-containers.containers.hass = {
          image = "homeassistant/home-assistant:latest";
          environment = {
            TZ = "Europe/Berlin";
            UMASK = "007";
          };
          # Host networking here = the *container's* netns: HA binds directly on
          # the container's LAN IP (0.0.0.0:8123) and nginx below reaches it on
          # localhost, keeping the reverse-proxy peer at 127.0.0.1 so HA's
          # trusted_proxies = [ 127.0.0.1 ] still applies unchanged.
          extraOptions = [
            "--network=host"
            # habluetooth adapter recovery + aiodhcpwatcher passive DHCP
            # discovery need these; otherwise the integrations log missing
            # NET_ADMIN/NET_RAW capabilities on every restart.
            "--cap-add=NET_ADMIN"
            "--cap-add=NET_RAW"
          ];
          volumes = [
            "${confdir}:/config"
            # Pin LAN DNS (host net cannot use podman --dns) so HA resolves the
            # *.lan names of the services it now reaches over the LAN.
            "${resolvConf}:/etc/resolv.conf:ro"
          ];
        };

        # nginx inside the container: hass.lan -> the container's own IP.
        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          virtualHosts."hass" = {
            serverAliases = [ "hass.euer" "hass.lan" "ha" "ha.lan" "hass.omo.w" "hass.omo.r" ];
            locations."/" = {
              proxyPass = "http://localhost:8123";
              proxyWebsockets = true;
            };
          };
        };

        # Container owns its LAN IP outright: serve nginx (:80) and HA (:8123).
        # These stay explicit because they must also be reachable over the euer
        # wireguard interface (hass.euer), which is deliberately NOT trusted.
        networking.firewall.allowedTCPPorts = [ 80 8123 ];

        # Trust the LAN side wholesale, mirroring omo's own
        # `trustedInterfaces = [ "br0" ]` (machines/omo/networking.nix). While HA
        # ran as podman --network=host on omo it inherited that trust; moving it
        # into this container put it behind a default-deny firewall and silently
        # broke every discovery/push protocol — Sonos most visibly:
        #   - SSDP NOTIFY  (multicast 239.255.255.250:1900) -> dropped
        #   - mDNS         (multicast 224.0.0.251:5353, _sonos._tcp) -> dropped
        #   - UPnP event callbacks the speakers POST back to HA on tcp/1400
        #     -> dropped, so subscriptions die and the players go unavailable
        # Verified with tcpdump on eth0: the bridge *does* deliver the multicast,
        # it is the container's nixos-fw INPUT chain that discards it.
        # Opening the individual ports is not sufficient: M-SEARCH replies are
        # unicast from the speaker's :1900 to an ephemeral port, and conntrack
        # cannot match them to the request because that request was sent to a
        # multicast destination — they arrive as NEW and get dropped. The same
        # applies to the other LAN-discovered integrations here (esphome, wled,
        # ipp, dlna, aiodhcpwatcher).
        networking.firewall.trustedInterfaces = [ "eth0" ];

        system.stateVersion = "24.05";
      };
  };
}
