{ pkgs, lib, ... }:
let
    port = 3011;
    state_dir = "/media/silent/db/karakeep";
    data_dir = "${state_dir}/data";
    meili_data_dir = "/media/silent/db/meili/data";
    meili_snapshot_dir = "/media/silent/db/meili/snapshot";
    meili_dump_dir = "/media/silent/db/meili/dump";
in
    {
  systemd.tmpfiles.settings = {
    "10-hoarder-state-dir" = {
      "${state_dir}" = {
        d = {
          group = "root";
          mode = "0700";
          user = "root";
        };
      };
    };
    "10-hoarder-data-dir" = {
      "${data_dir}" = {
        d = {
          group = "root";
          mode = "0777";
          user = "root";
        };
      };
    };
    "10-meili-dirs" = {
      "${meili_snapshot_dir}".d.user ="meilisearch";
      "${meili_dump_dir}".d.user ="meilisearch";
      "${meili_data_dir}".d.user ="meilisearch";
    };
};
    users.groups.meilisearch = { };
    users.users.meilisearch = {
      isSystemUser = true;
      group = "meilisearch";
  };
  systemd.services.meilisearch.serviceConfig = {
      User = "meilisearch";
      Group = "meilisearch";
      DynamicUser = false;
      # ReadWritePaths is already set by nixos module to datadir,snapshotdir,
  };
    services.meilisearch.settings = {
        db_path = meili_data_dir;
        dump_dir = meili_dump_dir;
        snapshot_dir = meili_snapshot_dir;
    };
    services.karakeep = {
        enable = true;
        extraEnvironment = {
            PORT = toString port;
            DATA_DIR = data_dir;

        };
    };
}
