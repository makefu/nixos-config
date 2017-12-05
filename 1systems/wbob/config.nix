{ config, pkgs, lib, ... }:
let
  rootdisk = "/dev/disk/by-id/ata-TS256GMTS800_C613840115";
  datadisk = "/dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10006PH3A02F";
  user = config.makefu.gui.user;
  primaryIP = "192.168.8.11";
in {

  imports =
    [ # Include the results of the hardware scan.
      <stockholm/makefu>
      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/disable_v6.nix>
      # <stockholm/makefu/2configs/tools/core-gui.nix>
      # <stockholm/makefu/2configs/tools/extra-gui.nix>
      # <stockholm/makefu/2configs/tools/media.nix>
      <stockholm/makefu/2configs/virtualisation/libvirt.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      <stockholm/makefu/2configs/mqtt.nix>
      <stockholm/makefu/2configs/deployment/led-fader.nix>
      # <stockholm/makefu/2configs/gui/wbob-kiosk.nix>

      <stockholm/makefu/2configs/stats/client.nix>


      # <stockholm/makefu/2configs/gui/studio-virtual.nix>
      # <stockholm/makefu/2configs/audio/jack-on-pulse.nix>
      # <stockholm/makefu/2configs/audio/realtime-audio.nix>
      # <stockholm/makefu/2configs/vncserver.nix>

      # Services
      <stockholm/makefu/2configs/remote-build/slave.nix>
      <stockholm/makefu/2configs/share/wbob.nix>

      <stockholm/makefu/2configs/stats/telegraf>
      <stockholm/makefu/2configs/stats/telegraf/airsensor.nix>
      (let
          collectd-port = 25826;
          influx-port = 8086;
          grafana-port = 3000; # TODO nginx forward
          db = "collectd_db";
          logging-interface = "enp0s25";
        in {
          services.grafana.enable = true;
          services.grafana.addr = "0.0.0.0";

          services.influxdb.enable = true;
          services.influxdb.extraConfig = {
            meta.hostname = config.krebs.build.host.name;
            # meta.logging-enabled = true;
            http.bind-address = ":${toString influx-port}";
            admin.bind-address = ":8083";
            collectd = [{
              enabled = true;
              typesdb = "${pkgs.collectd}/share/collectd/types.db";
              database = db;
              bind-address = ":${toString collectd-port}";
            }];
          };

          networking.firewall.extraCommands = ''
            iptables -A INPUT -i ${logging-interface} -p udp --dport ${toString collectd-port} -j ACCEPT
            iptables -A INPUT -i ${logging-interface} -p tcp --dport ${toString influx-port} -j ACCEPT
            iptables -A INPUT -i ${logging-interface} -p tcp --dport ${toString grafana-port} -j ACCEPT

            ip6tables -A INPUT -i ${logging-interface} -p udp --dport ${toString collectd-port} -j ACCEPT
            ip6tables -A INPUT -i ${logging-interface} -p tcp --dport ${toString influx-port} -j ACCEPT
            ip6tables -A INPUT -i ${logging-interface} -p tcp --dport ${toString grafana-port} -j ACCEPT
          '';
      })

      # temporary
      # <stockholm/makefu/2configs/temp/rst-issue.nix>
  ];

  krebs = {
      enable = true;
      build.host = config.krebs.hosts.wbob;
  };

  swapDevices = [ { device = "/var/swap"; } ];
  services.collectd.extraConfig = lib.mkAfter ''

    #LoadPlugin ping
    # does not work because it requires privileges
    #<Plugin "ping">
    #  Host "google.de"
    #  Host "heise.de"
    #</Plugin>

    LoadPlugin curl
    <Plugin curl>
      TotalTime true
      NamelookupTime true
      ConnectTime true

      <Page "google">
        MeasureResponseTime true
        MeasureResponseCode true
        URL "https://google.de"
      </Page>

      <Page "webde">
        MeasureResponseTime true
        MeasureResponseCode true
        URL "http://web.de"
      </Page>

    </Plugin>
    #LoadPlugin netlink
    #<Plugin "netlink">
    #  Interface "enp0s25"
    #  Interface "wlp2s0"
    #  IgnoreSelected false
    #</Plugin>
  '';

  networking.firewall.allowedUDPPorts = [ 655 ];
  networking.firewall.allowedTCPPorts = [
    655
    8081 #smokeping
    49152
  ];
  networking.firewall.trustedInterfaces = [ "enp0s25" ];
  #services.tinc.networks.siem = {
  #  name = "display";
  #  extraConfig = ''
  #    ConnectTo = sjump
  #    Port = 1655
  #  '';
  #};

  # rt2870.bin wifi card, part of linux-unfree
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  networking.wireless.enable = true;
  # rt2870 with nonfree creates wlp2s0 from wlp0s20u2
  # not explicitly setting the interface results in wpa_supplicant to crash
  networking.wireless.interfaces = [ "wlp2s0" ];
  networking.interfaces.enp0s25.ip4 = [
    { address = primaryIP; prefixLength = 24;}
  ];
  networking.interfaces.virbr1.ip4 = [{
    address = "10.8.8.11";
    prefixLength = 24;
  }];


  # nuc hardware
  boot.loader.grub.device = rootdisk;
  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems = {
    "/" = {
      device = rootdisk + "-part1";
      fsType = "ext4";
    };
    "/data" = {
      device = datadisk + "-part1";
      fsType = "ext4";
    };
  };

  # DualHead on NUC
  # TODO: update synergy package with these extras (username)
  # TODO: add crypto layer
  systemd.services."synergy-client" = {
    environment.DISPLAY = ":0";
    serviceConfig.User = user;
  };

  services.synergy = {
    client = {
      enable = true;
      screenName = "wbob";
      serverAddress = "x.r";
    };
  };
  security.wrappers.fping = {
    source = "${pkgs.fping}/bin/fping";
    setuid = true;
  };
  services.smokeping = {
    enable = true;
    targetConfig = ''
      probe = FPing
      menu = Top
      title = Network Latency Grapher
      remark = Welcome to this SmokePing website.

      + network
      menu = Net latency
      title = Network latency (ICMP pings)

      ++ google
      probe = FPing
      host = google.de
      ++ webde
      probe = FPing
      host = web.de

      + services
      menu = Service latency
      title = Service latency (DNS, HTTP)

      ++ HTTP
      menu = HTTP latency
      title = Service latency (HTTP)

      +++ webdeping
      probe = EchoPingHttp
      host = web.de

      +++ googwebping
      probe = EchoPingHttp
      host = google.de

      #+++ webwww
      #probe = Curl
      #host = web.de

      #+++ googwebwww
      #probe = Curl
      #host = google.de
    '';
    probeConfig = ''
       + FPing
       binary = /run/wrappers/bin/fping
       + EchoPingHttp
       pings = 5
       url = /

       #+ Curl
       ## probe-specific variables
       #binary = ${pkgs.curl}/bin/curl
       #step = 60
       ## a default for this target-specific variable
       #urlformat = http://%host%/
    '';
  };
}
