{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.vbob;
  imports =
    [ # Include the results of the hardware scan.
      ../.
      <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
      ../2configs/main-laptop.nix #< base-gui

      # environment

    ];
  nixpkgs.config.allowUnfree = true;

  fileSystems."/nix" = {
    device ="/dev/disk/by-label/nixstore";
    fsType = "ext4";
  };
  #makefu.buildbot.master.enable = true;
  # allow vbob to deploy self
  users.extraUsers = {
    root = {
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu-vbob.pubkey  ];
    };
  };
  environment.systemPackages = with pkgs;[
    fortclientsslvpn
    buildbot
    buildbot-slave
    get
    logstash
  ];

  networking.firewall.allowedTCPPorts = [
    25
    80
    8010
  ];

  krebs.retiolum = {
    enable = true;
    #extraConfig = "Proxy = http global.proxy.alcatel-lucent.com 8000";
    connectTo = [
      "gum"
    ];
  };

  #networking.proxy.default = "http://global.proxy.alcatel-lucent.com:8000";
  fileSystems."/media/share" = {
    fsType = "vboxsf";
    device = "share";
    options = [ "rw" "uid=9001" "gid=9001" ];
  };

}
