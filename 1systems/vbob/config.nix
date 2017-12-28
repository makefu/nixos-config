{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.vbob;
  makefu.awesome.modkey = "Mod1";
  imports =
    [
      <stockholm/makefu>
      {
        imports = [<stockholm/makefu/2configs/fs/single-partition-ext4.nix> ];
        boot.loader.grub.device = "/dev/vda";
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


}
