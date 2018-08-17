{ pkgs, ... }:
{
  services.pcscd = {
    enable = true;
    plugins = with pkgs; [ ifdnfc ccid ];

  };
  environment.systemPackages = with pkgs; [
    # need to run ifdnfc-activate before usage
    ifdnfc
    # pcsc_scan
    pcsctools
  ];
  boot.blacklistedKernelModules = [
    "pn533" "pn533_usb"
    "nfc"
  ];
}
