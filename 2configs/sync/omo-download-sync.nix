{ pkgs, ... }:
{
    services.cachefilesd = {
        enable = true;
        # 2026-07-20: fscache grew to 70G on the 117G root disk and filled it
        # mid-rebuild. Move it off the root disk and make culling kick in well
        # before the target gets tight (defaults only cull at 7%/stop at 3%
        # free). The cachefiles kernel module cannot use fuse.mergerfs
        # (needs xattrs + open-by-handle on a real fs), so the cache lives on
        # the emptiest pool member directly instead of /media/cryptX.
        # Percentages are relative to that disk's size.
        cacheDir = "/media/crypt3/fscache";
        extraConfig = ''
          brun  25%
          bcull 22%
          bstop 20%
          frun  10%
          fcull 7%
          fstop 3%
        '';
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
