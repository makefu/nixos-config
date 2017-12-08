#
#
#
{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <stockholm/makefu>
      <stockholm/makefu/2configs/main-laptop.nix>
      <stockholm/makefu/2configs/tools/all.nix>
      <stockholm/makefu/2configs/fs/sda-crypto-root.nix>
      # hardware specifics are in here
      # imports tp-x2x0.nix
      # <stockholm/makefu/2configs/hw/tp-x200.nix>

      # <stockholm/makefu/2configs/rad1o.nix>

      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>
    ];
  # not working in vm
  krebs.build.host = config.krebs.hosts.tsp;
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; allowDiscards=true; }];
  boot.loader.grub.copyKernels = true;

  networking.firewall.allowedTCPPorts = [
    25
  ];

  # acer aspire
  networking.wireless.enable = lib.mkDefault true;

  services.xserver.synaptics.enable = true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  hardware.cpu.intel.updateMicrocode = true;

  zramSwap.enable = true;
  zramSwap.numDevices = 2;

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    # BUG: http://linrunner.de/en/tlp/docs/tlp-faq.html#erratic-battery
    START_CHARGE_THRESH_BAT0=67
    STOP_CHARGE_THRESH_BAT0=100


    CPU_SCALING_GOVERNOR_ON_AC=performance
    CPU_SCALING_GOVERNOR_ON_BAT=ondemand
    CPU_MIN_PERF_ON_AC=0
    CPU_MAX_PERF_ON_AC=100
    CPU_MIN_PERF_ON_BAT=0
    CPU_MAX_PERF_ON_BAT=30
  '';

  powerManagement.resumeCommands = ''
    ${pkgs.rfkill}/bin/rfkill unblock all
  '';

}
