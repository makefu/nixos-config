_:
{
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "vmw_pvscsi"
  ];
  boot.loader.grub.splashImage = null;
  nix = {
    daemonIONiceLevel = 1;
    daemonNiceLevel = 1;
  };
  sound.enable = false;
}
