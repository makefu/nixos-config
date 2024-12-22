{ pkgs, ... }:
{
  services.cachefilesd.enable = true;
  systemd.services.download-sync = {
    # startAt = "hourly";
    startAt = "*:0/30"; # 30 minutes
    path = [ pkgs.rsync ];
    script = ''
      rsync -a --size-only --omit-dir-times --no-perms --no-owner --progress --stats /media/cloud/download/. /media/crypt1/download/.
    '';
    serviceConfig = {
      User = "download";
      PrivateTmp = true;
    };
  };
}
