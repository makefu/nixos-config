{
  pkgs,
  config,
  lib,
  ...
}:
let
  internal-ip = "192.168.111.11";
  port = 4533;
  navidromeLocations = {
    "/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };
  cfg = config.services.navidrome;
in
{
  imports = [ ../cert-relay/client-euer.nix ];
  services.navidrome.enable = true;
  services.navidrome.settings = {
    #MusicFolder = "/media/cryptX/music/kinder";
    MusicFolder = "/media/silent/music";
    PlaylistsPath = "/media/silent/playlists";
    Address = "0.0.0.0";
  };
  sops.secrets.navidrome-secrets.owner = "navidrome";
  systemd.services.navidrome = {
    serviceConfig = {
      Restart = "always";
      RestartSec = "15";
      EnvironmentFile = config.sops.secrets.navidrome-secrets.path;
      ExecStartPre = pkgs.writers.writeDash "lol" "echo LND_LASTFM_APIKEY $ND_LASTFM_APIKEY";
      BindReadOnlyPaths = [
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
  # Relayed HTTPS: 3modules/cert-relay.nix generates
  # music.euer.syntax-fehler.de (onlySSL + the relayed LE wildcard cert).
  makefu.cert-relay.euer.client.nginxVhosts = {
    music = {
      locations = navidromeLocations;
    };
  };
  services.nginx.virtualHosts."navidrome" = {
    serverAliases = [
      "navidrome.lan"
      "music"
      "music.lan"
      "musik"
      "musik.lan"
      "music.omo.r"
      "music.makefu.r"
      "music.makefu"
    ];
    locations = navidromeLocations;
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
