{
  inputs,
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
}
