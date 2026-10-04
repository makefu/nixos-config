{ config, lib, pkgs, ... }:
let
  cfg = config.makefu.mediaGuard;
  guardScript = pkgs.writeScript "media-unmounted-guard" ''
    #!${pkgs.bash}/bin/bash
    # Lock mountpoints while their data disks are absent so early services
    # fail fast (EPERM) instead of writing stray trees onto the rootfs, which
    # the later mount then hides. mount(2) still works on immutable dirs
    # (verified on btrfs/xfs, including bind and mergerfs/fuse), so a failed
    # or late mount is never blocked by the guard itself.
    set -u
    for p in ${lib.escapeShellArgs cfg.paths}; do
      d=$(stat -c %d "$p" 2>/dev/null) || d=""
      pd=$(stat -c %d "$(dirname "$p")" 2>/dev/null) || pd=""
      # different device than the parent => already mounted => no guard
      if [ -n "$d" ] && [ "$d" != "$pd" ]; then
        continue
      fi
      mkdir -p "$p"
      ${pkgs.e2fsprogs.bin}/bin/chattr +i "$p"
    done
  '';
in
{
  options.makefu.mediaGuard.paths = lib.mkOption {
    type = with lib.types; listOf str;
    default = [ ];
    description = ''
      Mountpoint directories that must not be writable on the underlying
      (rootfs) filesystem while their real filesystem is not mounted.
      A boot-time oneshot locks each unmounted path with chattr +i;
      systemd-tmpfiles and service ExecStartPre writes then fail instead of
      creating orphan directories that are hidden once the disk mounts.
    '';
  };

  config = lib.mkIf (cfg.paths != [ ]) {
    systemd.services.media-unmounted-guard = {
      description = "Lock unmounted media mountpoints against early writes";
      wantedBy = [ "local-fs.target" ];
      before = [ "local-fs.target" ];
      # run even though it produces no mount
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = guardScript;
      };
    };
  };
}
