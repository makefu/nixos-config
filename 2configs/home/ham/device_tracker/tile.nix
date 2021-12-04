{

  services.home-assistant.config.device_tracker =
  [
    { inherit (import <secrets/hass/tile.nix>) username password;
      platform = "tile";
      show_inactive = true;
    }
  ];
}
