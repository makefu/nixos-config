{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs; [
    kodi
    streamripper
    youtube-dl
    calibre
    vlc
    mumble
    mplayer
  ];
}
