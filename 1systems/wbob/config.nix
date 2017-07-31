{ config, pkgs, lib, ... }:
let
  rootdisk = "/dev/disk/by-id/ata-TS256GMTS800_C613840115";
  datadisk = "/dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10006PH3A02F";
  user = config.makefu.gui.user;
in {

  imports =
    [ # Include the results of the hardware scan.
      <stockholm/makefu>
      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/core-gui.nix>
      <stockholm/makefu/2configs/tools/extra-gui.nix>
      <stockholm/makefu/2configs/tools/media.nix>
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
      <stockholm/makefu/2configs/temp/rst-issue.nix>
    ];

  krebs = {
      enable = true;
      build.host = config.krebs.hosts.wbob;
  };

  swapDevices = [ { device = "/var/swap"; } ];


  networking.firewall.allowedUDPPorts = [ 655 ];
  networking.firewall.allowedTCPPorts = [ 655 49152 ];
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
}
