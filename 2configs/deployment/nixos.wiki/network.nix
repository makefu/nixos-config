{
  networking.networkmanager.unmanaged = [ "interface-name:ve-*" ];
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlan0";
}
