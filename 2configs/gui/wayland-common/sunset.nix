{ config, ... }:
let
    mainUser = config.krebs.build.user.name;
in {
    home-manager.users.${mainUser}.services.wlsunset = {
        enable = true;
        latitude = "49";
        longitude = "9";
    };
}
