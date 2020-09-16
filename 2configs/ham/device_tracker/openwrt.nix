[
  { platform = "luci";
    host = "192.168.1.5";
    username = "root";
    password = import <secrets/hass/router.nix>;
    interval_seconds = 30; # instead of 12seconds
    consider_home = 300; # 5 minutes timeout
    new_device_defaults.track_new_devices = true;
  }
]
