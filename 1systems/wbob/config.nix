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
      # <stockholm/makefu/2configs/disable_v6.nix>
      <stockholm/makefu/2configs/tools/core-gui.nix>
      <stockholm/makefu/2configs/tools/extra-gui.nix>
      <stockholm/makefu/2configs/tools/media.nix>
      <stockholm/makefu/2configs/virtualisation/libvirt.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      <stockholm/makefu/2configs/mqtt.nix>
      <stockholm/makefu/2configs/gui/wbob-kiosk.nix>

      # <stockholm/makefu/2configs/gui/studio-virtual.nix>
      # <stockholm/makefu/2configs/audio/jack-on-pulse.nix>
      # <stockholm/makefu/2configs/audio/realtime-audio.nix>
      # <stockholm/makefu/2configs/vncserver.nix>

      # Services
      # <stockholm/makefu/2configs/hydra/stockholm.nix>

      <stockholm/makefu/2configs/share/wbob.nix>
      <stockholm/makefu/2configs/bluetooth-mpd.nix>

      # Sensors
      <stockholm/makefu/2configs/stats/client.nix>
      <stockholm/makefu/2configs/stats/collectd-client.nix>
      <stockholm/makefu/2configs/stats/telegraf>
      <stockholm/makefu/2configs/stats/telegraf/airsensor.nix>
      <stockholm/makefu/2configs/stats/telegraf/europastats.nix>
      <stockholm/makefu/2configs/stats/external/aralast.nix>
      <stockholm/makefu/2configs/stats/arafetch.nix>
      <stockholm/makefu/2configs/deployment/led-fader.nix>
      <stockholm/makefu/2configs/hw/mceusb.nix>
      # <stockholm/makefu/2configs/stats/telegraf/bamstats.nix>
      { environment.systemPackages = [ pkgs.vlc ]; }

      {
        # Risikoübernahme
        nixpkgs.config.permittedInsecurePackages = [
          "homeassistant-0.77.2"
        ];
      }
      <stockholm/makefu/2configs/bureautomation>
      <stockholm/makefu/2configs/bureautomation/mpd.nix>
      <stockholm/makefu/2configs/bureautomation/hass.nix>
      (let
          collectd-port = 25826;
          influx-port = 8086;
          admin-port = 8083;
          grafana-port = 3000; # TODO nginx forward
          db = "collectd_db";
          logging-interface = "enp0s25";
        in {
          networking.firewall.allowedTCPPorts = [ 3000 influx-port admin-port ];

          services.grafana.enable = true;
          services.grafana.addr = "0.0.0.0";
          services.influxdb.enable = true;
          services.influxdb.extraConfig = {
            meta.hostname = config.krebs.build.host.name;
            # meta.logging-enabled = true;
            http.bind-address = ":${toString influx-port}";
            admin.bind-address = ":${toString admin-port}";
            collectd = [{
              enabled = true;
              typesdb = "${pkgs.collectd}/share/collectd/types.db";
              database = db;
              bind-address = ":${toString collectd-port}";
            }];
          };

          networking.firewall.extraCommands = ''
            iptables -A INPUT -i ${logging-interface} -p tcp --dport ${toString grafana-port} -j ACCEPT
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
  networking.interfaces.virbr1.ipv4.addresses = [{
    address = "10.8.8.11";
    prefixLength = 24;
  }];


  # nuc hardware
  boot.loader.grub.device = rootdisk;
  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];

  boot.kernelModules = [ "kvm-intel"
    "snd-seq" "snd-rawmidi"
  ];
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
}
