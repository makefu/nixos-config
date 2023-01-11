{ lib, config, ... }:
{
        services.jellyfin.enable = true;
        services.jellyfin.openFirewall = true;
        state = [ "/var/lib/jellyfin" ];
        users.users.${config.services.jellyfin.user}.extraGroups = [ "video" "render" ];

}
