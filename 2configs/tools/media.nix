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
    yt-dlp

    pulseeffects-legacy # for pulse
  ];
}
