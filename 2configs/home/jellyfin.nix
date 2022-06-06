{ lib, config, ... }:
{
        services.jellyfin.enable = true;
        services.jellyfin.openFirewall = true;
        #users.users.${config.services.jellyfin.user}.extraGroups = [ "download" "video" "render" ];
        state = [ "/var/lib/jellyfin" ];
        systemd.services.jellyfin.serviceConfig.PrivateDevices = lib.mkForce false;
        systemd.services.jellyfin.serviceConfig.DeviceAllow = lib.mkForce ["char-drm rwm" "char-nvidia-frontend" "char-nvidia-uvm"];
        systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [ "video" "render" "download" ];
}
