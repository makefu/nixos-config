{ config, lib, ... }:
with import <stockholm/lib>;
let
  base-dir = config.services.rtorrent.downloadDir;
in {
  users.users = {
    download = {
      name = "download";
      home = base-dir;
      isNormalUser = true;
      uid = mkDefault (genid "download");
      createHome = false;
      useDefaultShell = true;
      group = "download";
      openssh.authorizedKeys.keys = [ ];
    };
  };

  users.groups = {
    download = {
      gid = lib.mkDefault (genid "download");
      members = [
        config.krebs.build.user.name
        "download"
      ];
    };
  };

}
