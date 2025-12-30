{ lib, nixos-hardware, ... }:
{
    imports = [
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen1-nvidia
    ];
    services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
    # test this
    # nixpkgs.config.cudaSupport = true;

}
