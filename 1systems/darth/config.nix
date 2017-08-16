{ config, pkgs, lib, ... }:

with import <stockholm/lib>;
let
  byid = dev: "/dev/disk/by-id/" + dev;
  rootDisk = byid "ata-INTEL_SSDSC2BW480H6_CVTR53120385480EGN";
  bootPart = rootDisk + "-part1";
  rootPart = rootDisk + "-part2";

  allDisks = [ rootDisk ]; # auxDisk
in {
  imports = [
      <stockholm/makefu>
      <stockholm/makefu/2configs/fs/sda-crypto-root.nix>
      <stockholm/makefu/2configs/sshd-totp.nix>
      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/smart-monitor.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      # <stockholm/makefu/2configs/virtualisation/libvirt.nix>

      <stockholm/makefu/2configs/tinc/retiolum.nix>
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/stats/client.nix>
      <stockholm/makefu/2configs/nsupdate-data.nix>

      # SIEM
      #<stockholm/makefu/2configs/tinc/siem.nix>
      # {services.tinc.networks.siem = {
      #     name = "sdarth";
      #     extraConfig = "ConnectTo = sjump";
      #   };
      # }

      # {
      #   makefu.forward-journal = {
      #     enable = true;
      #     src = "10.8.10.2";
      #     dst = "10.8.10.6";
      #   };
      # }

      ## Sharing
      # <stockholm/makefu/2configs/share/temp-share-samba.nix>
      #{
      #  services.samba.shares = {
      #      isos = {
      #        path = "/data/isos/";
      #        "read only" = "yes";
      #        browseable = "yes";
      #        "guest ok" = "yes";
      #      };
      #  };
      #}
      <stockholm/makefu/2configs/share/anon-ftp.nix>
  ];



  #networking.firewall.enable = false;
  makefu.server.primary-itf = "enp0s25";
  krebs.hidden-ssh.enable = true;
  boot.kernelModules = [ "coretemp" "f71882fg" ];
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  networking = {
    wireless.enable = true;
    firewall = {
      allowPing = true;
      logRefusedConnections = false;
      # trustedInterfaces = [ "eno1" ];
      allowedUDPPorts = [ 80 655 1655 67 ];
      allowedTCPPorts = [ 80 655 1655 ];
    };
    # fallback connection to the internal virtual network
    # interfaces.virbr3.ip4 =  [{
    #   address = "10.8.8.2";
    #   prefixLength = 24;
    # }];
  };

  # TODO smartd omo darth gum all-in-one
  services.smartd.devices = builtins.map (x: { device = x; }) allDisks;

  boot.loader.grub.device = rootDisk;
  boot.initrd.luks.devices = [
    { name = "luksroot";
      device = rootPart;
      allowDiscards = true;
      keyFileSize = 4096;
      keyFile = "/dev/sdb";
    }
  ];

  krebs.build.host = config.krebs.hosts.darth;
}
