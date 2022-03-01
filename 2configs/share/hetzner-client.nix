{ config, lib, pkgs, ... }:

with <stockholm/lib>;
let
  automount_opts =
  [ "x-systemd.automount"
    "noauto" "x-systemd.idle-timeout=600"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
  ];
  host = "u288834.your-storagebox.de";
in {
  boot.kernel.sysctl."net.ipv6.route.max_size" = 2147483647;

  fileSystems."/media/cloud" = {
      device = "//${host}/backup";
      fsType = "cifs";
      options = automount_opts ++
      [ "credentials=${toString <secrets/hetzner.smb>}"
        "file_mode=0770"
        "dir_mode=0770"
        "uid=${toString config.users.users.download.uid}"
        "gid=${toString config.users.groups.download.gid}"
        #"vers=3"
        "vers=2.1"
        "rsize=65536"
        "wsize=130048"
        "iocharset=utf8"
      ];
  };
}
