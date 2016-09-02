{config, lib, pkgs, ... }:

{
  systemd.user.services.duply-secrets = {
    description = "run daily secrets backup";
    startAt = "daily";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "{pkgs.duply}/bin/duply omo-secrets backup";
    };
  };
}
