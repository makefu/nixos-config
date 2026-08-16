{ config, ... }:
let
    mainUser = "makefu";
in {
    home-manager.users.${mainUser}.services.wlsunset = {
        enable = true;
        latitude = "49";
        longitude = "9";
    };
}
