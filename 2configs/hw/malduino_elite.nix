{ config, lib, pkgs, ... }:

{

  services.udev.extraRules = ''
    ACTION!="add|change", GOTO="mm_usb_device_blacklist_local_end"
    SUBSYSTEM!="usb", GOTO="mm_usb_device_blacklist_local_end"
    ENV{DEVTYPE}!="usb_device", GOTO="mm_usb_device_blacklist_local_end"

    ATTRS{idVendor}=="1b4f" ATTRS{idProduct}=="9204", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="1b4f" ATTRS{idProduct}=="9203", ENV{ID_MM_DEVICE_IGNORE}="1"

    LABEL="mm_usb_device_blacklist_local_end"
  '';
}
