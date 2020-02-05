{ config, lib, pkgs, buildPythonPackage, ... }:
with import <stockholm/lib>;
let
  pkg = pkgs.ampel;
  home = "/var/lib/ampel";
  sec = "${toString <secrets>}/ampel/google-muell.json";
  ampelsec = "${home}/google-muell.json";
  cred = "${toString <secrets>}/ampel/google-muell-creds.json";
  # TODO: generate this credential file locally
  ampelcred = "${home}/google-muell-creds.json";
  sleepval = "1800";
  # default-color = "18,63,40";
  default-color = "255,127,0";
  config_json = toFile "config.json" (toJSON {
    mq_hostname = "localhost";
    mq_port = 1883;
    mq_username = "sensor";
    mq_topic = "/ham/flurlicht/cmnd/MEM1";
    mq_password = replaceChars ["\n"] [""] (readFile "${toString <secrets>}/mqtt/sensor");
  });
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
      ExecStart = "${pkg}/bin/google-muell --config ${config_json} --default-color=${default-color} --client-secrets=${ampelsec} --credential-path=${ampelcred} --sleepval=${sleepval}";
      PermissionsStartOnly = true;
      Restart = "always";
      RestartSec = 10;
      PrivateTmp = true;
    };
  };
}
