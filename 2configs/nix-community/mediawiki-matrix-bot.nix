{ pkgs, config, ... }:

{
  sops.secrets."mediawikibot-config.json" = {
    mode = "0440";
    group = config.users.groups.mediawiki.name;
  };
  users.groups.mediawiki = {};

  systemd.services.mediawiki-matrix-bot = {
    description = "Mediawiki Matrix Bot";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "60s";
      DynamicUser = true;
      StateDirectory = "mediawiki-matrix-bot";
      SupplementaryGroups = [ config.users.groups.mediawiki.name ];

      ExecStart = "${pkgs.mediawiki-matrix-bot}/bin/mediawiki-matrix-bot ${config.sops.secrets."mediawikibot-config.json".path}";
      PrivateTmp = true;
    };
  };
}
