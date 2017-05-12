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
  users.users."${user}".extraGroups = [ "audio" ];
}
