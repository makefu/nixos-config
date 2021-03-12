{ lib, ... }:
{
  imports = [
    # laptop is an acer aspire, but close enough i'd say
    <stockholm/makefu/2configs/hw/tp-x2x0.nix>
  ];
  # the laptop only has the touchpad
  services.xserver.synaptics.additionalOptions = lib.mkForce ''Option "TouchpadOff" "0"'';
}
