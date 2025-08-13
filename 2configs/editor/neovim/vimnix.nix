{ self,pkgs, ... }:
{
  usesers.users.makefu.packages = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.nvim
  ];
}
