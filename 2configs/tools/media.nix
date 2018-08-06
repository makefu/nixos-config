{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    kodi
    streamripper
    youtube-dl
    calibre
    vlc
    mumble
    mplayer
  ];
}
