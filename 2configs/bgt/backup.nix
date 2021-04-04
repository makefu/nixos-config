{
  # Manual steps:
  # 1. ssh-copy-id root ssh-key to the remotes you want to back up
  # 2. run `rsnapshot hourly` manually as root to check if everything works

  services.rsnapshot = {
    enable = true;
    cronIntervals = {
      daily = "50 21 * * *";
      hourly = "0 */4 * * *";
    };
    extraConfig = ''
retain	hourly	5
retain	daily	365
snapshot_root	/var/backup/bgt
backup	root@binaergewitter.jit.computer:/opt/isso	jit
backup	root@binaergewitter.jit.computer:/etc/systemd/system/isso.service	jit
backup	root@binaergewitter.jit.computer:/etc/nginx/conf.d/isso.conf	jit
    '';
  };
}
