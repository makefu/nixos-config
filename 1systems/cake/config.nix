{ config, pkgs, ... }:
{
    imports = [
        <stockholm/makefu>
        # configure your hw:
        # <stockholm/makefu/2configs/hw/CAC.nix>
        # <stockholm/makefu/2configs/fs/CAC-CentOS-7-64bit.nix>
        # <stockholm/makefu/2configs/save-diskspace.nix
    ];
    krebs = {
        enable = true;
        tinc.retiolum.enable = true;
        build.host = config.krebs.hosts.cake;
    };
    # You want to change these :)
    boot.loader.grub.device = "/dev/sda";
    fileSystems."/" = {
        device = "/dev/sda1";
    };
}