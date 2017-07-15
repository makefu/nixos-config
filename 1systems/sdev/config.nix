{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.sdev;
  makefu.awesome.modkey = "Mod1";
  imports =
    [ # Include the results of the hardware scan.
      <stockholm/makefu>
      (toString <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>)
      (toString <nixpkgs/nixos/modules/virtualisation/virtualbox-guest.nix>)
      <stockholm/makefu/2configs/main-laptop.nix #< base-gui>
      # <secrets/extra-hosts.nix>

      # environment
      <stockholm/makefu/2configs/tinc/retiolum.nix>

    ];
  # workaround for https://github.com/NixOS/nixpkgs/issues/16641
  services.xserver.videoDrivers = lib.mkOverride 45 [ "virtualbox" "modesetting" ];

  nixpkgs.config.allowUnfree = true;

  # allow sdev to deploy self
  users.extraUsers = {
    root = {
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu-vbob.pubkey  ];
    };
  };

  environment.systemPackages = with pkgs;[
    ppp xclip
    get
    passwdqc-utils
    docker
    gnupg
    populate
    (pkgs.writeScriptBin "tor-browser" ''
      #! /bin/sh
      TOR_SKIP_LAUNCH=1 ${torbrowser}/bin/tor-browser
    '')
  ];

  virtualisation.docker.enable = true;

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
