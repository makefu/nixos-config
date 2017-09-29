{pkgs, ...}:
{
  users.users.makefu.packages = [
    (pkgs.steam.override {
      newStdcpp = true;
    })
  ];
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
