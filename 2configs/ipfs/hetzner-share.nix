{config, ... }:
let
  dir = config.services.kubo.dataDir;
  uid = config.users.users.ipfs.uid;
  gid = config.users.groups.download.gid;
  # Prevents boot from hanging if the share is unavailable
  automount_opts = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s"];
in
  {
  sops.secrets."ipfs.smb" = {};
  fileSystems."${dir}" = {
    device = "//u288834-sub2.your-storagebox.de/u288834-sub2";
    fsType = "cifs";
    options = automount_opts ++ [
      # authorization
      "credentials=${config.sops.secrets."ipfs.smb".path}"
      # user perms
      "file_mode=0770"
      "dir_mode=0770"
      "uid=${toString uid}"
      "gid=${toString gid}"
      # performance
      "vers=3"
      "fsc"
      "rsize=65536"
      "wsize=130048"
      "iocharset=utf8"
      "cache=loose"
    ];
  };
}
