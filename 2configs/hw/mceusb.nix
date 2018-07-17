{pkgs,...}:{
  # Disable the MCE remote from acting like a keyboard.  (We use lirc instead.)
  services.xserver.inputClassSections = [''
    Identifier   "MCE USB Keyboard mimic blacklist"
    Driver       "mceusb"
    MatchProduct "Media Center Ed. eHome Infrared Remote Transceiver (1934:5168)"
    Option       "Ignore" "on"
  ''];
  boot.kernelPackages = builtins.trace "Using linux kernel 4.16, not latest" pkgs.linuxPackages_4_16;
  nixpkgs.config.packageOverrides = pkgs: {
    linux_4_16 = pkgs.linux_4_16.override {
        extraConfig = ''
          LIRC y
        '';
    };
  };

}
