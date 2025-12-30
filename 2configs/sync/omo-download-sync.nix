{ pkgs, ... }:
{
    services.cachefilesd = {
        enable = true;
        cacheDir = "/var/lib/cache/fscache";
    };
  systemd.services.download-sync = {
    # startAt = "hourly";
    startAt = "*:0/30"; # 30 minutes
    path = [ pkgs.rsync ];
    script = ''
      rsync -a --omit-dir-times --chmod=Du=rwx,Dg=rwx,Do=rx,Fu=rw,Fg=rw,Fo=r --no-perms --no-owner --progress --stats /media/cloud/download/. /media/crypt1/download/.
    '';
    serviceConfig = {
      User = "download";
      PrivateTmp = true;
      Umask = "0660";
    };
  };
}
