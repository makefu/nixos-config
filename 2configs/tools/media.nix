{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    kodi
    calibre
    vlc
    mumble
    mplayer
    # quodlibet # exfalso
    tinymediamanager

    plowshare
    streamripper
    youtube-dl

    pulseeffects
  ];
}
