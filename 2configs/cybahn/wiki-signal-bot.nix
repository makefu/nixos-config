{ pkgs, config, ... }:

let
    name = "mediawiki-signal-bot-sshg";
in
{
  sops.secrets."${name}.json" = {
    mode = "0440";
    group = config.users.groups.mediawiki.name;
  };
  users.groups.mediawiki = {};

  systemd.services.${name} = {
    description = "Mediawiki Signal Bot (sshg.cybahn.de)";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "60s";
      DynamicUser = true;
      StateDirectory = "${name}.wiki";
      SupplementaryGroups = [ config.users.groups.mediawiki.name ];

      ExecStart = "${pkgs.mediawiki-matrix-bot}/bin/mediawiki-matrix-bot ${config.sops.secrets."${name}.json".path}";
      PrivateTmp = true;
    };
  };
}
