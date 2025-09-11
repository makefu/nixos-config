{ lib, ... }:
{
    hardware.nvidia.open = false;
    services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
}
