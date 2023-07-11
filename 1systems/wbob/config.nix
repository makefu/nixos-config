{ config, pkgs, lib, ... }:
let
  user = config.makefu.gui.user;
  primaryIP = "192.168.8.11";
in {

  imports =
    [
      ../../2configs/default.nix
      # Include the results of the hardware scan.
      ./nuc


      ../../2configs/home-manager
      ../../2configs/support-nixos.nix
      ../../2configs/zsh-user.nix
      ../../2configs/tools/core.nix
      # ../../2configs/disable_v6.nix
      ../../2configs/tools/core-gui.nix
      ../../2configs/tools/extra-gui.nix
      ../../2configs/tools/media.nix
      # ../../2configs/virtualisation/libvirt.nix
      # ../../2configs/virtualisation/virtualbox.nix

      ../../2configs/tinc/retiolum.nix
      ../../2configs/gui/wbob-kiosk.nix
      ../../2configs/secrets/wbob-users.nix
      { environment.systemPackages = with pkgs ;[
        nano
        guake
      ]; }

      # ../../2configs/gui/studio-virtual.nix
      # ../../2configs/audio/jack-on-pulse.nix
      # ../../2configs/audio/realtime-audio.nix
      # ../../2configs/vncserver.nix
      ## no need for dns logs anymore
      # ../../2configs/logging/server.nix

      # Services
      # ../../2configs/hydra/stockholm.nix

      ../../2configs/share/wbob.nix
      ../../2configs/wireguard/thierry.nix
      ../../2configs/bluetooth-mpd.nix

      # Sensors
      # ../../2configs/stats/client.nix
      # ../../2configs/stats/collectd-client.nix
      ../../2configs/stats/telegraf
      ../../2configs/stats/telegraf/airsensor.nix
      ../../2configs/stats/telegraf/europastats.nix
      ../../2configs/stats/external/aralast.nix
      ../../2configs/stats/arafetch.nix
      # ../../2configs/hw/mceusb.nix
      ../../2configs/hw/slaesh.nix
      # ../../2configs/stats/telegraf/bamstats.nix
      { environment.systemPackages = [ pkgs.vlc ]; }

      ../../2configs/bureautomation # new hass entry point
      ../../2configs/bureautomation/led-fader.nix
      ../../2configs/bureautomation/printer.nix
      # ../../2configs/bureautomation/kalauerbot.nix now runs in thales
      # ../../2configs/bureautomation/visitor-photostore.nix
      # ../../2configs/bureautomation/mpd.nix #mpd is only used for TTS, this is the web interface
      ../../2configs/mqtt.nix
      {
        services.mjpg-streamer = {
          enable = true;
          inputPlugin = "input_uvc.so -d /dev/video0 -r 640x480 -y -f 30 -q 50 -n";
          outputPlugin = "output_http.so -w @www@ -n -p 18088";
        };
      }
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
          systemd.services.influxdb.serviceConfig.LimitNOFILE = 8192;

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

      ../../2configs/backup/state.nix
      # temporary
      # ../../2configs/temp/rst-issue.nix
      {
        services.jellyfin.enable = true;
      }
  ];

  krebs = {
      enable = true;
      build.host = config.krebs.hosts.wbob;
  };

  networking.firewall.allowedUDPPorts = [ 655 ];
  networking.firewall.allowedTCPPorts = [
    655
    8081 # smokeping
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
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  # rt2870.bin wifi card, part of linux-unfree
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;
  # rt2870 with nonfree creates wlp2s0 from wlp0s20u2
  # not explicitly setting the interface results in wpa_supplicant to crash
  #networking.interfaces.virbr1.ipv4.addresses = [{
  #  address = "10.8.8.11";
  #  prefixLength = 24;
  #}];
  # nuc hardware
}
