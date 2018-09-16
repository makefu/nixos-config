{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    kodi
    calibre
    vlc
    mumble
    mplayer
    quodlibet

    plowshare
    streamripper
    youtube-dl
  ];
}
