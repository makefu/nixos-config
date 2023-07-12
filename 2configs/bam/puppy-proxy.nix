{ pkgs, ... }:
# streamlink 'https://www.ustream.tv/channel/maximilian-schnauzers-cam4' worst --player-external-http --player-external-http-port 15321 --player-passthrough rtsp --retry-streams 60
{
  environment.systemPackages = [ pkgs.liveproxy ];
}
