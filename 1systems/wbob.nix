{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/main-laptop.nix
    ];
  krebs = {
      enable = true;
      retiolum.enable = true;
      build.host = config.krebs.hosts.wbob;
  };

  # rt2870.bin wifi card, part of linux-unfree
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  networking.wireless.enable = true;
  # rt2870 with nonfree creates wlp2s0 from wlp0s20u2
  # not explicitly setting the interface results in wpa_supplicant to crash
  networking.wireless.interfaces = [ "wlp2s0" ];


  # nuc hardware
  boot.loader.grub.device = "/dev/sda";
  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
  };

  # DualHead on NUC
  services.xserver = {
      # xrandrHeads = [ "HDMI1" "HDMI2" ];
      # prevent screen from turning off, disable dpms
      displayManager.sessionCommands = ''
        xset s off -dpms
        xrandr --output HDMI2 --right-of HDMI1
      '';
  };
  ## TODO Awesomecfg + autostart chrome
  #
  #local current_screen = 1
  #awful.rules.rules = {
  #  { rule = { class = "chromium-browser" },
  #    callback = function()
  #      awful.client.movetotag(tags[current_screen][1],c)
  #      if (current_screen == 1) then
  #        current_screen = current_screen+1
  #      else
  #        current_screen = current_screen-1
  #      end
  #    end
  #  },
  #}
  #awful.util.spawn_with_shell("chromium --new-window --kiosk http://wolf:3000/dashboard/db/soc-critical-values")
  # prevent Race Condition
  #awful.util.spawn_with_shell("sleep 0.5;chromium --new-window --kiosk http://wolf:3000/dashboard/db/aralast")

}
