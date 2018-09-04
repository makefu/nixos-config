{ config, lib, pkgs, ... }:

let
  automount_opts =
  [ "x-systemd.automount"
    "noauto" "x-systemd.idle-timeout=600"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
  ];
  host = "nextgum"; #TODO
in {
  fileSystems."/media/download" = {
      device = "//${host}/download";
      fsType = "cifs";
      options = automount_opts ++
      [ "credentials=/var/src/secrets/download.smb"
        "file_mode=0775"
        "dir_mode=0775"
        "uid=9001"
      ];
  };

}
