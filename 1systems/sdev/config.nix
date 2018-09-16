{ lib, config, pkgs, ... }:
{
  krebs.build.host = config.krebs.hosts.sdev;
  makefu.awesome.modkey = "Mod1";
  imports =
    [ # Include the results of the hardware scan.
      <stockholm/makefu>

       <stockholm/makefu/2configs/hw/vbox-guest.nix>
      #{ # until virtualbox-image is fixed
      #  imports = [
      #      <stockholm/makefu/2configs/fs/single-partition-ext4.nix>
      #    ];
      #  boot.loader.grub.device = lib.mkForce "/dev/sda";
      #}
      <stockholm/makefu/2configs/main-laptop.nix>
      # <secrets/extra-hosts.nix>

      # environment
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>

    ];
  # allow sdev to deploy self
  users.extraUsers = {
    root = {
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu-vbob.pubkey  ];
    };
  };
  # corefonts
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs;[
    ppp xclip
    get
    passwdqc-utils
    gnupg
    populate
    (pkgs.writeScriptBin "tor-browser" ''
      #! /bin/sh
      TOR_SKIP_LAUNCH=1 ${torbrowser}/bin/tor-browser
    '')
  ];

  networking.firewall.allowedTCPPorts = [
    25
    80
    8010
  ];


}
