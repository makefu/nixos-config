{pkgs, config, ...}:
{
	services.collectd = {
    enable = true;
    autoLoadPlugin = true;
    extraConfig = ''
			Hostname ${config.krebs.build.host.name}
			LoadPlugin load
			LoadPlugin disk
			LoadPlugin memory
			LoadPlugin df
			Interval 30.0

			LoadPlugin interface
			<Plugin "interface">
				Interface "*Link"
				Interface "lo"
				Interface "vboxnet*"
				Interface "virbr*"
				IgnoreSelected true
			</Plugin>

			LoadPlugin df
      <Plugin "df">
        MountPoint "/nix/store"
        # MountPoint "/run*"
        # MountPoint "/sys*"
        # MountPoint "/dev"
        # MountPoint "/dev/shm"
        # MountPoint "/tmp"
        FSType "tmpfs"
        FSType "binfmt_misc"
        FSType "debugfs"
        FSType "mqueue"
        FSType "hugetlbfs"
        FSType "systemd-1"
        FSType "cgroup"
        FSType "securityfs"
        FSType "ramfs"
        FSType "proc"
        FSType "devpts"
        FSType "devtmpfs"
        MountPoint "/var/lib/docker/devicemapper"
				IgnoreSelected true
      </Plugin>

			LoadPlugin cpu
			<Plugin cpu>
				ReportByCpu true
				ReportByState true
				ValuesPercentage true
			</Plugin>

      LoadPlugin network
      <Plugin "network">
          Server "${config.makefu.stats-server}" "25826"
      </Plugin>
    '';
  };
}
