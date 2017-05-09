{ config, pkgs, ... }:
{
  imports = [
    ../.

  ];
  krebs = {
    enable = true;
    tinc.retiolum.enable = true;
    build.host = config.krebs.hosts.studio;
  };

  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ];
    uid = 1000;
  };

  environment.systemPackages = with pkgs;[
    pavucontrol
    firefox
    chromium
  ];

  sound.enable = true;
  hardware.pulseaudio = {
     enable = true;
     systemWide = true;
  };

  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [ ];
  };
  # ingos favorite display manager
  services.xserver.displayManager.sddm = {
    enable = true;
    autoLogin.enable = true;
    autoLogin.user = "user";
  };
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.xkbOptions = "ctrl:nocaps";

  i18n = {
    consoleKeyMap = "us-int";
    defaultLocale = "en_US.UTF-8";
  };



  # hardware
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0aeda516-230e-4c54-9e27-13515c2f3f21";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/1914af67-5a8f-41d3-a1c2-211c39605da9"; } ];
}
