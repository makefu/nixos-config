{ config, lib, pkgs, buildPythonPackage, ... }:
with import <stockholm/lib>;
let
  pkg = pkgs.ampel;
  home = "/var/lib/ampel";
  sec = "${toString <secrets>}/google-muell.json";
  ampelsec = "${home}/google-muell.json";
  esp = "192.168.1.23";
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
        cp ${sec} ${ampelsec}
        chown ampel ${ampelsec}
      '';
      ExecStart = "${pkg}/bin/google-muell --esp=${esp} --client-secrets=${ampelsec} --credential-path=${home}/google-muell-creds.json --sleepval=${sleepval}";
      PermissionsStartOnly = true;
      Restart = "always";
      RestartSec = 10;
      PrivateTmp = true;
    };
  };
}
