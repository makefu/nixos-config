{pkgs, ...}:
{
  environment.systemPackages = [ 
    (pkgs.steam.override {
      newStdcpp = true;
    })
  ];
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
