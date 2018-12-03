{ config, lib, pkgs, buildPythonPackage, ... }:
with import <stockholm/lib>;
let
  pkg = pkgs.ampel;
  home = "/var/lib/ampel";
  sec = "${toString <secrets>}/google-muell.json";
  ampelsec = "${home}/google-muell.json";
  cred = "${toString <secrets>}/google-muell-creds.json";
  # TODO: generate this credential file locally
  ampelcred = "${home}/google-muell-creds.json";
  esp = "192.168.8.204";
  sleepval = "1800";
in {
  users.users.ampel = {
    uid = genid "ampel";
    createHome = true;
    isSystemUser = true;
    inherit home;
  };
  systemd.services.google-muell-ampel = {
    description = "Send led change to rgb cubes";
    after = [ "network-online.target"  ];
    wantedBy = [ "multi-user.target"  ];
    serviceConfig = {
      User = "ampel";
      ExecStartPre = pkgs.writeDash "copy-ampel-secrets" ''
        install -m600 -o ampel ${sec} ${ampelsec}
        install -m600 -o ampel ${cred} ${ampelcred}
      '';
      ExecStart = "${pkg}/bin/google-muell --esp=${esp} --client-secrets=${ampelsec} --credential-path=${ampelcred} --sleepval=${sleepval}";
      PermissionsStartOnly = true;
      Restart = "always";
      RestartSec = 10;
      PrivateTmp = true;
    };
  };
}
