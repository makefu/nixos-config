{config, ...}:
{
  # fdisk /dev/sda
  # mkfs.ext4 -L nixos /dev/sda1
  boot.loader.grub.enable = assert config.boot.loader.grub.device != ""; true;
  boot.loader.grub.version = 2;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
