{ config, pkgs, ... }:
{
    imports =
      [
        ../2configs/fs/single-partition-ext4.nix
        ../2configs/zsh-user.nix
      ];
    krebs = {
        enable = true;
        retiolum.enable = true;
        build.host = config.krebs.hosts.darth;
    };
    # You want to change these :)
    boot.loader.grub.device = "/dev/sda";
}
