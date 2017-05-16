{ config, pkgs, ... }:
let
  user = config.makefu.gui.user;
in
{
  imports = [
    ../sources/musnix.nix # populate musnix
    <musnix>
  ];
  musnix.enable = true;
  musnix.kernel.optimize = true;
  musnix.kernel.realtime = true;
  # TODO: musnix.kernel.packages = pkgs.linuxPackages_latest_rt;

  users.users."${user}".extraGroups = [ "audio" ];
}
