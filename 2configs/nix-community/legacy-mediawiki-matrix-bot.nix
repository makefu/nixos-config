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
      RestartSec = "60s";
      DynamicUser = true;
      StateDirectory = "mediawiki-matrix-bot-nixos.wiki";
      SupplementaryGroups = [ config.users.groups.mediawiki.name ];

      ExecStart = "${pkgs.mediawiki-matrix-bot}/bin/mediawiki-matrix-bot ${config.sops.secrets."mediawikibot-config-nixos.wiki.json".path}";
      PrivateTmp = true;
    };
  };
}
