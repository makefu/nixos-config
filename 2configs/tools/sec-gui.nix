{ pkgs, ... }:

{
  users.users.makefu = {
    extraGroups = [ "wireshark" ];
    packages = with pkgs; [
      tpmmanager
    ];
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
