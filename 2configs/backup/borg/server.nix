{lib,config, ... }:
let
  hosts = lib.mapAttrsToList (f: _: lib.removeSuffix ".pub" f) (builtins.readDir ./ssh );
in {
  # TODO: for all enabled machines
  options = {
    makefu.backup.server.repo = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/borgbackup";
    };
  };
  config = {
    services.borgbackup.repos = lib.genAttrs hosts (host: {
      authorizedKeys = [ (builtins.readFile (./ssh + "/${host}.pub") ) ];
      path = "${config.makefu.backup.server.repo}/${host}";
      user = "borg-${host}";
    }) ;
  };
}
