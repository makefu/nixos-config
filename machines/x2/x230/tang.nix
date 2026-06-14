{ lib, ... }:
{
  boot.initrd.systemd.tpm2.enable = lib.mkForce false;
  boot.initrd.clevisLuksAskpass.enable = true;
  boot.initrd.clevisLuksAskpass.useTang = true;
  boot.initrd.clevis = {
    enable = true;
    useTang = true;

    devices."rpool/root".secretFile = ./zroot.key.jwe;
  };
  boot.initrd.availableKernelModules = [
    "virtio_net"
    "e1000"
    "e1000e"
    "igb"
    "igc"
    "r8169"
  ];
  boot.initrd.systemd.network = {
    enable = true;
    networks."10-uplink" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
    };
  };
}
