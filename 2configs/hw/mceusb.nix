{pkgs, lib, ...}:{
  # Disable the MCE remote from acting like a keyboard.  (We use lirc instead.)
  services.xserver.inputClassSections = [''
    Identifier   "MCE USB Keyboard mimic blacklist"
    Driver       "mceusb"
    MatchProduct "Media Center Ed. eHome Infrared Remote Transceiver (1934:5168)"
    Option       "Ignore" "on"
  ''];
  boot.kernelPatches = lib.singleton {
    name = "enable-lirc";
    patch = null;
    extraConfig = ''
      LIRC y
    '';
  };

}
