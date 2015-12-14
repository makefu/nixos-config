#
#
#
{ config, pkgs, ... }:

{
  krebs.build.host = config.krebs.hosts.vbob;
  krebs.build.target = "root@10.10.10.220";
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
      ../2configs/main-laptop.nix #< base-gui

      # environment
      ../2configs/zsh-user.nix
      ../2configs/virtualization.nix
    ];
  nixpkgs.config.packageOverrides = pkgs: { tinc = pkgs.tinc_pre; };
  environment.systemPackages = with pkgs;[
    get
    ];

  networking.firewall.allowedTCPPorts = [
    25
    80
  ];

  krebs.retiolum = {
    enable = true;
    extraConfig = "Proxy = http global.proxy.alcatel-lucent.com 8000";
    hosts = ../../krebs/Zhosts;
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
