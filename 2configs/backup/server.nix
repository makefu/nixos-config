{lib, ... }:
let
  hosts = lib.mapAttrsToList (f: _: lib.removeSuffix ".pub" f) (builtins.readDir ./ssh );
in {
  # TODO: for all enabled machines
  services.borgbackup.repos = lib.genAttrs hosts (host: {
    authorizedKeys = [ (builtins.readFile (./ssh + "/${host}.pub") ) ];
    path = "/var/lib/borgbackup/${host}";
    user = "borg-${host}";
  }) ;
}
