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
      <secrets/extra-hosts.nix>

      # environment
      ../2configs/tinc/retiolum.nix

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

  virtualisation.docker.enable = false;

  fileSystems."/media/share" = {
    fsType = "vboxsf";
    device = "share";
    options = [ "rw" "uid=9001" "gid=9001" ];
  };

}
