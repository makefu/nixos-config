{ pkgs, inputs, ... }:
let
    outdir = "/var/lib/bibchecker";
    pkg = inputs.bibchecker.packages.${pkgs.system}.default;
in {
  systemd.services.bibchecker = {
    description = "bibchecker-web";
    wantedBy = [ "multi-user.target" ];
    environment = {
      FLASK_PORT = "3001";
      FLASK_HOST = "0";
      BIB_INPUT_FILE = "${outdir}/STUFF";
      BIB_OUTPUT_DIR = outdir;
      BIB_CACHE_FILE = "${outdir}/cache.json";
    };
    serviceConfig = {
      StateDirectory = "bibchecker";
      WorkingDirectory = outdir;
      ExecStart = "${pkg}/bin/bibchecker-web";
      DynamicUser = true;
      Restart = "always";
    };
  };

}
