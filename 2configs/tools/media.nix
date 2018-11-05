{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    kodi
    calibre
    vlc
    mumble
    mplayer
    quodlibet # exfalso

    plowshare
    streamripper
    youtube-dl

    pulseeffects
  ];
}
