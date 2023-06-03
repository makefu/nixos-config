{ config, lib, pkgs, ... }:

let
  automount_opts =
  [ "x-systemd.automount" "noauto" 
    "x-systemd.idle-timeout=300"
    "x-systemd.mount-timeout=60s"
  ];
  host = "gum.w"; #TODO
in {
  boot.extraModprobeConfig = ''
    options cifs CIFSMaxBufSize=130048
  '';
  fileSystems."/media/cloud" = {
      device = "//${host}/cloud-proxy";
      fsType = "cifs";
      options = automount_opts ++
      [ "credentials=/var/src/secrets/download.smb"
        "file_mode=0775"
        "dir_mode=0775"
        "bsize=8388608"
        "fsc"
        "rsize=130048"
        "cache=loose"
        "uid=${toString config.users.users.download.uid}"
        "gid=${toString config.users.groups.download.gid}"
        "vers=3"
      ];
  };

}
