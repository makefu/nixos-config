{config, lib, ... }:
let
    db-dir = "/media/silent/db/continuwuity";
    user = config.services.matrix-continuwuity.user;
    statedir = config.services.matrix-continuwuity.settings.global.database_path;

in
{
    # create matrix db-dir
    systemd.tmpfiles.settings."01-matrix-db-dir"."${db-dir}".d = {
        inherit user;
        mode = "0700";
        group = "root";
    };
    # symlink to statedir
    systemd.tmpfiles.settings."02-matrix-db-symlink".${statedir}."L+" = {
        inherit user;
        mode = "0700";
        group = "root";
        argument = db-dir;
    };
    sops.secrets.matrix_registration_token.owner = user;
    services.matrix-continuwuity = {
        enable = true;
        settings.global = {
            server_name = "matrix.euer.krebsco.de";
            address = ["0.0.0.0"] ;
            allow_registration = true;
            registration_token  = config.sops.secrets.matrix_registration_token.path;
            allow_federation = false;
        };
    };
    # use oure created statedir symlink instead of the statedirectory mechanism
    systemd.services.continuwuity.serviceConfig = {
        StateDirectory = lib.mkForce false;
        DynamicUser = lib.mkForce false;
        PrivateMounts = lib.mkForce false;
        ProtectSystem = lib.mkForce "full";
    };
}
