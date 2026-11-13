{
  config,
  lib,
  pkgs,
  ...
}:

{
  # M-VAVE FM-1 / SMK-37 in JieLi USB download mode (4c4a:8057, USB disk
  # "WL82 UBOOT1.00"). M-Flasher drives it with SCSI ioctls, so the sg driver
  # has to be loaded (there is no /dev/sg* without it) and the devices need to
  # belong to the logged-in user, otherwise the flasher only works as root.
  # The uaccess rules ship with the package (lib/udev/rules.d), so let the
  # udev module install them instead of duplicating them here:
  # https://github.com/jvitkauskas/m-flasher/blob/main/linux/70-m-flasher.rules
  boot.kernelModules = [ "sg" ];

  services.udev.packages = [ pkgs.m-flasher ];

  environment.systemPackages = [ pkgs.m-flasher ];
}
