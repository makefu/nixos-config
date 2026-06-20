{ config, pkgs, lib, self, ... }:
{
  imports =
    [
      ./x230
      # do not build in tmpfs

      ../../2configs/performance/nix-performance.nix
      ../../2configs/default.nix
      ../../2configs/hw/network-manager.nix
      ../../2configs/performance/disable-mitigations.nix


      # secrets: now deployed once at host provisioning
      # ../../2configs/backup/restic/state.nix

      ../../2configs/avahi.nix
       ../../2configs/virtualisation/libvirt.nix
      #../../2configs/virtualisation/docker.nix
      #../../2configs/virtualisation/virtualbox.nix

      ../../2configs/wireguard/euer/client.nix
    ];


}
