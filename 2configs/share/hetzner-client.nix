{ config, lib, pkgs, ... }:

let
  automount_opts = ["nofail" "_netdev" "soft" "x-systemd.automount"];
  host = "u288834.your-storagebox.de";
in {
  boot.kernel.sysctl."net.ipv6.route.max_size" = 2147483647;
  sops.secrets."hetzner.smb" = {};

  fileSystems."/media/cloud" = {
      device = "//${host}/backup";
      fsType = "cifs";
      options = automount_opts ++
      [ "credentials=${config.sops.secrets."hetzner.smb".path}"
        "file_mode=0770"
        "dir_mode=0770"
        "uid=${toString config.users.users.download.uid}"
        "gid=${toString config.users.groups.download.gid}"
        "vers=3"
        "fsc"
        "rsize=65536"
        "wsize=130048"
        "iocharset=utf8"
        "cache=loose"
      ];
  };
}
