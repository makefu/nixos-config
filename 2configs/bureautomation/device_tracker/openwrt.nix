# requires `opkg install luci-mod-rpc` on router
# see https://www.home-assistant.io/components/luci/

[
  { platform = "luci";
    host = "192.168.8.1";
    username = "root";
    password = import <secrets/hass/router.nix>;
    interval_seconds = 30; # instead of 12seconds
    consider_home = 300; # 5 minutes timeout
    new_device_defaults = {
      track_new_devices = true;
      hide_if_away = false;
    };
  }
]
