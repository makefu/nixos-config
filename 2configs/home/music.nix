{ config,lib, ... }:
let
  internal-ip = "192.168.111.11";
  port = 4533;
  cfg = config.services.navidrome;
in
{
  services.navidrome.enable = true;
  services.navidrome.settings = {
    #MusicFolder = "/media/cryptX/music/kinder";
    MusicFolder = "/media/silent/music";
    PlaylistsPath = "/media/silent/playlists";
    Address = "0.0.0.0";
  };
  systemd.services.navidrome = {
    serviceConfig = {
      Restart = "always";
      RestartSec = "15";
      BindReadOnlyPaths =
        [
          # navidrome uses online services to download additional album metadata / covers
          "${
            config.environment.etc."ssl/certs/ca-certificates.crt".source
          }:/etc/ssl/certs/ca-certificates.crt"
          builtins.storeDir
          "/etc"
        ]
        ++ lib.optional (cfg.settings ? MusicFolder) cfg.settings.MusicFolder
        ++ lib.optionals config.services.resolved.enable [
          "/run/systemd/resolve/stub-resolv.conf"
          "/run/systemd/resolve/resolv.conf"
        ];
    };
    unitConfig.RequiresMountsFor = [ "/media/silent" ];
  };

  state = [ "/var/lib/navidrome" ];
  # networking.firewall.allowedTCPPorts = [ 4040 ];
  # state = [ config.services.airsonic.home ];
  services.nginx.virtualHosts."navidrome" = {
    serverAliases = [
              "navidrome.lan"
      "music"  "music.lan"
      "musik" "musik.lan"
      "music.omo.r"
      "music.makefu.r" "music.makefu"
    ];

    locations."/".proxyPass = "http://localhost:${toString port}";
    locations."/".proxyWebsockets = true;
  };
  networking.firewall.allowedTCPPorts = [ port ];
  # also configure dlna
  services.minidlna.enable = true;
  services.minidlna.settings = {
    inotify = "yes";
    friendly_name = "omo";
    media_dir = [ "A,/media/silent/music" ];
  };
}
