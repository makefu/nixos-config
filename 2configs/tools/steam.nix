{pkgs, ...}:
{
  users.users.makefu.packages = [
    pkgs.steam
  ];
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
