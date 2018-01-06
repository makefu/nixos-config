{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.vbob;
  makefu.awesome.modkey = "Mod1";
  imports =
    [
      <stockholm/makefu>
      {
        imports = [<stockholm/makefu/2configs/fs/single-partition-ext4.nix> ];
        boot.loader.grub.device = "/dev/sda";
        virtualisation.virtualbox.guest.enable = true;
      }
      # {
      #   imports = [
      #     <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
      #   ];
      #   virtualbox.baseImageSize = 35 * 1024;
      #   fileSystems."/media/share" = {
      #     fsType = "vboxsf";
      #     device = "share";
      #     options = [ "rw" "uid=9001" "gid=9001" ];
      #   };
      # }

      # {
      #   imports = [
      #     <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
      #   ];
      #   fileSystems."/nix" = {
      #     device ="/dev/disk/by-label/nixstore";
      #     fsType = "ext4";
      #   };
      # }


      # base gui
      # <stockholm/makefu/2configs/main-laptop.nix>
      # <stockholm/makefu/2configs/tools/core-gui.nix>

      <stockholm/makefu/2configs/zsh-user.nix>

      # security
      <stockholm/makefu/2configs/sshd-totp.nix>

      # Tools
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/dev.nix>
      # <stockholm/makefu/2configs/tools/extra-gui.nix>
      # <stockholm/makefu/2configs/tools/sec.nix>

      # environment
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      (let
        gum-ip = config.krebs.hosts.gum.nets.internet.ip4.addr;
        gateway = "10.0.2.2";
      in {
        # make sure the route to gum gets added after the network is online
        systemd.services.wireguard-wg0.after = [ "network-online.target" ];
        networking.wireguard.interfaces.wg0 = {
          ips = [ "10.244.0.3/24" ];
          privateKeyFile = (toString <secrets>) + "/wireguard.key";
          # explicit route via eth0 to gum
          preSetup = ["${pkgs.iproute}/bin/ip route add ${gum-ip} via ${gateway}"];
          peers = [
          { # gum
            endpoint = "${gum-ip}:51820";
            allowedIPs = [ "0.0.0.0/0" "10.244.0.0/24" ];
            publicKey = "yAKvxTvcEVdn+MeKsmptZkR3XSEue+wSyLxwcjBYxxo=";
            persistentKeepalive = 25;
          }
          ];
        };
      })

    ];
  networking.extraHosts = import (toString <secrets/extra-hosts.nix>);

  nixpkgs.config.allowUnfree = true;

  # allow vbob to deploy self
  users.extraUsers = {
    root = {
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu-vbob.pubkey  ];
    };
  };

  environment.shellAliases = {
    forti  = "cat ~/vpn/pw.txt | xclip; sudo forticlientsslvpn";
  };

  system.activationScripts.prepare-fortclientvpnssl = ''
    # TODO: for forticlientsslpn
    mkdir -p /usr/{s,}bin
    ln -fs ${pkgs.ppp}/bin/pppd /usr/sbin/pppd
    ln -fs ${pkgs.coreutils}/bin/tail /usr/bin/tail
  '';
  environment.systemPackages = with pkgs;[
    fortclientsslvpn ppp xclip
    get
    logstash
  #  docker
    #devpi-web
    #devpi-client
    ansible
  ];
  # virtualisation.docker.enable = true;


  networking.firewall.allowedTCPPorts = [
    25
    80
    8010
  ];

  systemd.services."serial-getty@ttyS0".enable = true;
}
