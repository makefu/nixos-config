{config, lib, pkgs, ... }:

{
  options.makefu.dl-dir = lib.mkOption {
    type = lib.types.str;
    description = "Default download directory";
    default = "/media/cryptX/torrent";
  };
  options.makefu.torrent-secrets = lib.mkOption {
    type = lib.types.str;
    default = "/home/makefu/secrets/torrent";
  };
}
