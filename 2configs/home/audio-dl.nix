{ inputs, pkgs, ... }:
let
  pkg = inputs.audio-scripts.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  users.users.makefu.packages = [
    pkg
  ];
  systemd.services.mausdownload = {
    startAt = "6:15:00";
    path = [ pkg ];
    script = "alldownload.sh /media/silent/music/kinder/podcasts";
    serviceConfig= {
      User = "download"; # TODO unprivileged user
      # yt-dlp narrates every extraction step of every podcast episode
      # ("[generic] feed: Downloading webpage", download progress, …), ~12k
      # journal lines per daily run. Its own diagnostics are prefixed
      # WARNING:/ERROR: instead of a [tag] and still get through.
      LogFilterPatterns = [ "~^\\[[A-Za-z][A-Za-z:_+-]*\\] " ];
    };
  };
}
