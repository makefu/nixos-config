{ lib, pkgs, config, ... }:
let
  port = 8096;
  # jellyfin has no NixOS option for its serilog config, it reads
  # <dataDir>/config/logging.json (falling back to the shipped
  # logging.default.json). Same as the default, except the scheduled task
  # manager: the webhook plugin runs its notifier tasks every ~90s and each run
  # logs two "Completed after 0 minute(s)" lines.
  loggingConfig = pkgs.writeText "jellyfin-logging.json" (builtins.toJSON {
    Serilog = {
      MinimumLevel = {
        Default = "Information";
        Override = {
          "Microsoft" = "Warning";
          "System" = "Warning";
          "Emby.Server.Implementations.ScheduledTasks" = "Warning";
        };
      };
      WriteTo = [
        {
          Name = "Console";
          Args.outputTemplate =
            "[{Timestamp:HH:mm:ss}] [{Level:u3}] [{ThreadId}] {SourceContext}: {Message:lj}{NewLine}{Exception}";
        }
        {
          # kept so the log viewer in jellyfin's dashboard keeps working
          Name = "Async";
          Args.configure = [
            {
              Name = "File";
              Args = {
                path = "%JELLYFIN_LOG_DIR%//log_.log";
                rollingInterval = "Day";
                retainedFileCountLimit = 3;
                rollOnFileSizeLimit = true;
                fileSizeLimitBytes = 100000000;
                outputTemplate =
                  "[{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz}] [{Level:u3}] [{ThreadId}] {SourceContext}: {Message}{NewLine}{Exception}";
              };
            }
          ];
        }
      ];
      Enrich = [ "FromLogContext" "WithThreadId" ];
    };
  });
in
{
  services.jellyfin = {
    enable = true;
    group = "download";
    dataDir = "/media/silent/db/jellyfin";
    cacheDir = "/media/silent/cache/jellyfin";
    #openFirewall = true;
  };
  networking.firewall.interfaces.wiregrill = {
    allowedTCPPorts = [ 80 port 8920 ];
    allowedUDPPorts = [ 1900 7359 ];
  };
  state = [ config.services.jellyfin.dataDir ];
  systemd.tmpfiles.rules = [
    "L+ ${config.services.jellyfin.dataDir}/config/logging.json - - - - ${loggingConfig}"
  ];
  users.users.${config.services.jellyfin.user}.extraGroups = [ "download" "video" "render" ];

  systemd.services.jellyfin = {
    after = [ "media-cloud.mount" ];
    serviceConfig = rec {
      # RequiresMountsFor = [ "/media/cloud" ];
      SupplementaryGroups = lib.mkForce [ "video" "render" "download" ];
      UMask = lib.mkForce "0007";
    };
  };
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
  services.nginx.virtualHosts."jelly" = {
    serverAliases = [
      "jelly.lan" "movies.lan"
      "jelly.makefu.w"  "makefu.omo.w"
      "movies.euer" "jelly.euer"
    ];

    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };
}
