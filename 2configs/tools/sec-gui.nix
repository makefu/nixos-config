{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs; [
    tpmmanager
    wireshark
  ];
}
