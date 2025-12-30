{ pkgs, ... }:
{
  services.pcscd = {
    enable = true;
    plugins = with pkgs; 
    [ #ifdnfc
      ccid
    ];

  };
  environment.systemPackages = with pkgs; [
    # need to run ifdnfc-activate before usage
    # ifdnfc
    # pcsc_scan
    pcsc-tools
  ];
  boot.blacklistedKernelModules = [
    "pn533" "pn533_usb"
    "nfc"
  ];
}
