{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.vbob;
  makefu.awesome.modkey = "Mod1";
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
  fileSystems."/var/lib/docker" = {
    device ="/dev/disk/by-label/nix-docker";
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
    get
    logstash
    docker
    devpi-web
    devpi-client
  ];
  # virtualisation.docker.enable = true;


  networking.firewall.allowedTCPPorts = [
    25
    80
    8010
  ];

  krebs.retiolum = {
    enable = true;
    connectTo = [
      "omo"
      "gum"
    ];
  };

  networking.extraHosts = ''
    172.17.20.190  gitlab
    172.17.62.27   svbittool01 tool
  '';

  fileSystems."/media/share" = {
    fsType = "vboxsf";
    device = "share";
    options = [ "rw" "uid=9001" "gid=9001" ];
  };

}
