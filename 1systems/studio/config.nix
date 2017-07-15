{ config, pkgs, ... }:
{
  imports = [
    <stockholm/makefu>
    <stockholm/makefu/2configs/vncserver.nix>
    <stockholm/makefu/2configs/vim.nix>
    <stockholm/makefu/2configs/disable_v6.nix>
    <stockholm/makefu/2configs/audio/jack-on-pulse.nix>
    <stockholm/makefu/2configs/audio/realtime-audio.nix>
    <stockholm/makefu/2configs/gui/studio.nix>
    <stockholm/makefu/2configs/binary-cache/lass.nix>

  ];
  makefu.gui.user = "user"; # we use an extra user
  krebs = {
    enable = true;
    tinc.retiolum.enable = true;
    build.host = config.krebs.hosts.studio;
  };
  networking.firewall.allowedTCPPorts = [ 655 ];
  networking.firewall.allowedUDPPorts = [ 655 ];


  environment.systemPackages = with pkgs;[
    # audio foo
    ## pulseaudio
    pavucontrol
    paprefs
    pamixer

    # extra alsa tools
    alsa-hdspconf
    alsa-hdspmixer
    alsa-hdsploader

    # recording
    darkice
    (mumble.override { jackSupport = true; })

    # browsing
    firefox
    chromium
  ];


  nixpkgs.config.allowUnfree = true;
  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [ ];
  };
  # ingos favorite display manager


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
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ];
    uid = 1000;
    openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
  };
}
