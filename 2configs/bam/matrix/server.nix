{config, ... }:
let
    db-dir = "/media/silent/db/continuwuity";
    user = config.services.matrix-continuwuity.user;
in
{
    # create matrix db-dir
    systemd.tmpfiles.settings."matrix-db-dir".d = {
        inherit user;
        mode = "0700";
        group = "root";
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
            database_path = db-dir;
        };
    };
}
