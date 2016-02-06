#
#
#
{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.vbob;
  krebs.build.target = "root@10.10.10.220";
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
      ../2configs/main-laptop.nix #< base-gui

      # environment

    ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    tinc = pkgs.tinc_pre;
  };

  makefu.buildbot.master = {
    enable = false;
    irc = {
      enable = true;
      server = "cd.retiolum";
      channel = "retiolum";
      allowForce = true;
    };
  };
  # services.logstash.enable = true;
  makefu.buildbot.slave = {
    enable = false;
    masterhost = "localhost";
    username = "testslave";
    password = "krebspass";
    packages = with pkgs;[ git nix ];
    extraEnviron = { NIX_PATH="nixpkgs=${toString <nixpkgs>}"; };
  };

  krebs.build.source.git.nixpkgs = {
    #url = https://github.com/nixos/nixpkgs;
    # HTTP Everywhere + libredir
    rev = "8239ac6";
  };
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
    genid
    logstash
  ];

  networking.firewall.allowedTCPPorts = [
    25
    80
    8010
  ];

  krebs.retiolum = {
    enable = true;
    extraConfig = "Proxy = http global.proxy.alcatel-lucent.com 8000";
    connectTo = [
      "gum"
    ];
  };

  networking.proxy.default = "http://global.proxy.alcatel-lucent.com:8000";
  fileSystems."/media/share" = {
    fsType = "vboxsf";
    device = "share";
    options = "rw,uid=9001,gid=9001";
  };

}

