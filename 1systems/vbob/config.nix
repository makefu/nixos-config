{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.vbob;
  makefu.awesome.modkey = "Mod1";
  imports =
    [ # Include the results of the hardware scan.
      <stockholm/makefu>
      (toString <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>)
      (toString <nixpkgs/nixos/modules/virtualisation/virtualbox-guest.nix>)
      # base gui
      <stockholm/makefu/2configs/main-laptop.nix>

      # security
      <stockholm/makefu/2configs/sshd-totp.nix>

      # Tools
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/core-gui.nix>
      <stockholm/makefu/2configs/tools/dev.nix>
      <stockholm/makefu/2configs/tools/extra-gui.nix>
      <stockholm/makefu/2configs/tools/sec.nix>

      # environment
      <stockholm/makefu/2configs/tinc/retiolum.nix>

      <stockholm/makefu/2configs/audio/jack-on-pulse.nix>
      <stockholm/makefu/2configs/audio/realtime-audio.nix>

    ];
  networking.extraHosts = import (toString <secrets/extra-hosts.nix>);

  nixpkgs.config.allowUnfree = true;
  fileSystems."/nix" = {
    device ="/dev/disk/by-label/nixstore";
    fsType = "ext4";
  };

  # allow vbob to deploy self
  users.extraUsers = {
    root = {
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu-vbob.pubkey  ];
    };
  };

  environment.shellAliases = {
    forti  = "cat ~/vpn/pw.txt | xclip; sudo forticlientsslvpn";
  };
  # TODO: for forticleintsslpn
  #       ln -s /r/current-system/sw/bin/pppd /usr/sbin/pppd
  #       ln -s /r/current-system/sw/bin/tail /usr/bin/tail
  environment.systemPackages = with pkgs;[
    fortclientsslvpn ppp xclip
    get
    logstash
  #  docker
    #devpi-web
    #devpi-client
    debmirror
    ansible
  ];
  # virtualisation.docker.enable = true;


  networking.firewall.allowedTCPPorts = [
    25
    80
    8010
  ];

  fileSystems."/media/share" = {
    fsType = "vboxsf";
    device = "share";
    options = [ "rw" "uid=9001" "gid=9001" ];
  };

}
