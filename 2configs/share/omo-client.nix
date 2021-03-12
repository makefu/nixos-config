{ config, lib, pkgs, ... }:

let
  automount_opts =
  [ "x-systemd.automount"
    "noauto" "x-systemd.idle-timeout=600"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
  ];
  host = "omo.lan"; #TODO
  path = "/media/omo/photos";
in {
  systemd.tmpfiles.rules = [
    "d ${path} root root - -"
  ];
  fileSystems."${path}" = {
      device = "//${host}/photos";
      fsType = "cifs";
      options = automount_opts ++
      [ "credentials=/var/src/secrets/omo-client.smb"
        "file_mode=0775"
        "dir_mode=0775"
        "uid=9001"
        "vers=3"
      ];
  };

}
