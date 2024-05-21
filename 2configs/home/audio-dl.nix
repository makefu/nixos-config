{ inputs, pkgs, ... }:
{
  users.users.makefu.packages = [
    inputs.audio-scripts.packages.${pkgs.system}.default
  ];
}
