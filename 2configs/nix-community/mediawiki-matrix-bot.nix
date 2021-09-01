{ pkgs, ... }:
let
  seccfg = toString <secrets/mediawikibot-config.json>;
  statecfg = "/var/lib/mediawiki-matrix-bot/config.json";
in {
  systemd.services.mediawiki-matrix-bot = {
    description = "Mediawiki Matrix Bot";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "60s";
      DynamicUser = true;
      StateDirectory = "mediawiki-matrix-bot";
      PermissionsStartOnly = true;
      ExecStartPre = pkgs.writeDash "mediawikibot-copy-config" ''
        install -D  -m644 ${seccfg} ${statecfg}
      '';
      ExecStart = "${pkgs.mediawiki-matrix-bot}/bin/mediawiki-matrix-bot ${statecfg}";
      PrivateTmp = true;
    };
  };
}
