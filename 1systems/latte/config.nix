{ config, lib, pkgs, ... }:
let

  # external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  # internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
  # default-gw = "185.215.224.1";
  # prefixLength = 24;
  # external-mac = "46:5b:fc:f4:44:c9";
  # ext-if = "et0";
in {

  imports = [
    ./1blu
    <stockholm/makefu>
    #<stockholm/makefu/2configs/home-manager>
    # configure your hw:
    #<stockholm/makefu/2configs/hw/CAC.nix>
    <stockholm/makefu/2configs/tinc/retiolum.nix>
    #<stockholm/makefu/2configs/save-diskspace.nix>

    # Security
    <stockholm/makefu/2configs/sshd-totp.nix>
    # <stockholm/makefu/2configs/stats/client.nix>

    # Tools
    <stockholm/makefu/2configs/tools/core.nix>
    <stockholm/makefu/2configs/zsh-user.nix>
    # Services
    <stockholm/makefu/2configs/remote-build/slave.nix>
    # <stockholm/makefu/2configs/torrent.nix>

  ];
  krebs = {
    enable = true;
    build.host = config.krebs.hosts.latte;
  };

}
