{ pkgs, config, ... }:

{
  sops.secrets."mediawikibot-config-nixos.wiki.json" = {
    mode = "0440";
    group = config.users.groups.mediawiki.name;
  };
  users.groups.mediawiki = {};

  systemd.services.mediawiki-matrix-bot-nixos-wiki = {
    description = "Mediawiki Matrix Bot (nixos.wiki)";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      # the bot exits when the matrix homeserver rate-limits its login, and a
      # 60s restart just feeds the rate limiter — it has been crashlooping ~10
      # times an hour, replaying its whole room list through nio's INFO logger
      # on every start. Back off far enough for the 429 window to expire.
      RestartSec = "15min";
      # nio logs one line per room and per room state event at startup
      LogFilterPatterns = [ "~^INFO:nio" ];
      DynamicUser = true;
      StateDirectory = "mediawiki-matrix-bot-nixos.wiki";
      SupplementaryGroups = [ config.users.groups.mediawiki.name ];

      ExecStart = "${pkgs.mediawiki-matrix-bot}/bin/mediawiki-matrix-bot ${config.sops.secrets."mediawikibot-config-nixos.wiki.json".path}";
      PrivateTmp = true;
    };
  };
}
