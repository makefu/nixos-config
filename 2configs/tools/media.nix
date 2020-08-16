{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    kodi
    calibre
    vlc
    mumble
    mplayer
    mpv
    # quodlibet # exfalso
    tinymediamanager

    plowshare
    streamripper
    youtube-dl

    pulseeffects
  ];
}
