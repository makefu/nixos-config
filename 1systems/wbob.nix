{ config, pkgs, ... }:
let rootdisk = "/dev/disk/by-id/ata-TS256GMTS800_C613840115";
in {

  makefu.awesome = {
    modkey = "Mod1";
    #TODO: integrate kiosk config into full config by templating the autostart
    baseConfig = pkgs.awesomecfg.kiosk;
  };
  imports =
    [ # Include the results of the hardware scan.
      ../.
      ../2configs/main-laptop.nix
      ../2configs/virtualization.nix
      ../2configs/tinc/retiolum.nix
    ];
  krebs = {
      enable = true;
      build.host = config.krebs.hosts.wbob;
  };
  networking.firewall.allowedUDPPorts = [ 1655 ];
  networking.firewall.allowedTCPPorts = [ 1655 49152 ];
  services.tinc.networks.siem = {
    name = "display";
    extraConfig = ''
      ConnectTo = sjump
    '';
  };

  # rt2870.bin wifi card, part of linux-unfree
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  networking.wireless.enable = true;
  # rt2870 with nonfree creates wlp2s0 from wlp0s20u2
  # not explicitly setting the interface results in wpa_supplicant to crash
  networking.wireless.interfaces = [ "wlp2s0" ];


  # nuc hardware
  boot.loader.grub.device = rootdisk;
  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems."/" = {
      device = rootdisk + "-part1";
      fsType = "ext4";
  };

  # DualHead on NUC
  services.xserver = {
      # xrandrHeads = [ "HDMI1" "HDMI2" ];
      # prevent screen from turning off, disable dpms
      displayManager.sessionCommands = ''
        xset s off -dpms
        xrandr --output HDMI2 --right-of HDMI1
      '';
  };
  # TODO: update synergy package with these extras (username)
  # TODO: add crypto layer
  systemd.services."synergy-client" = {
    environment.DISPLAY = ":0";
    serviceConfig.User = "makefu";
  };

  services.synergy = {
    client = {
      enable = true;
      screenName = "wbob";
      serverAddress = "pornocauster.r";
    };
  };
}
