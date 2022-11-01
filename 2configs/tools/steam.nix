{pkgs, ...}:
{
  users.users.makefu.packages = [
    pkgs.steam
  ];
  hardware.opengl.driSupport32Bit = true;
}
