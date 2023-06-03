{ pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.libraspberrypi ];
  imports = [ <nixos-hardware/raspberry-pi/4> ];
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  hardware.raspberry-pi."4".fkms-3d.enable = true; 
  hardware.raspberry-pi."4".audio.enable = true;  
}
