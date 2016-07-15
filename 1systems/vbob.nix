{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.vbob;
  makefu.awesome.modkey = "Mod1";
  imports =
    [ # Include the results of the hardware scan.
      ../.
      (toString <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>)
      (toString <nixpkgs/nixos/modules/virtualisation/virtualbox-guest.nix>)
      ../2configs/main-laptop.nix #< base-gui
      # (toString <secrets>)/extra-hosts.nix

      # environment

    ];
  # workaround for https://github.com/NixOS/nixpkgs/issues/16641
  services.xserver.videoDrivers = lib.mkOverride 45 [ "virtualbox" "modesetting" ];

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
  virtualisation.docker.enable = false;

  fileSystems."/media/share" = {
    fsType = "vboxsf";
    device = "share";
    options = [ "rw" "uid=9001" "gid=9001" ];
  };

}
