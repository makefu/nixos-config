{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.yamtrack.nixosModules.default
  ];
  services.yamtrack = {
    enable = true;
    database.createLocally = true;
    redis.createLocally = true;
    configureNginx = true;
    hostName = "track.euer";
  };
  # the bundled redis logs every RDB snapshot (one every 5 minutes) at notice
  services.redis.servers.yamtrack.settings.loglevel = lib.mkForce "warning";
}
