{ lib, config, ... }:
{
        services.jellyfin.enable = true;
        services.jellyfin.openFirewall = true;
        state = [ "/var/lib/jellyfin" ];
        users.users.${config.services.jellyfin.user}.extraGroups = [ "download" "video" "render" ];

        systemd.services.jellyfin = {

        after = [ "media-cloud.mount" ];
        serviceConfig = rec {
          SupplementaryGroups = lib.mkForce [ "video" "render" "download" ];
          UMask = lib.mkForce "0077";


        Type = lib.mkForce "simple";
        StateDirectory = lib.mkForce "jellyfin";
        StateDirectoryMode = lib.mkForce "0700";
        CacheDirectory = lib.mkForce "jellyfin";
        CacheDirectoryMode = lib.mkForce "0700";
        WorkingDirectory = lib.mkForce "/var/lib/jellyfin";
        Restart = lib.mkForce "on-failure";
        TimeoutSec = lib.mkForce 15;
        SuccessExitStatus = lib.mkForce ["0" "143"];

        # Security options:
        NoNewPrivileges = lib.mkForce true;
        SystemCallArchitectures = lib.mkForce "native";
        # AF_NETLINK needed because Jellyfin monitors the network connection
        RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
        RestrictNamespaces = lib.mkForce false;
        RestrictRealtime = lib.mkForce true;
        RestrictSUIDSGID = lib.mkForce true;
        ProtectControlGroups = lib.mkForce false;
        ProtectHostname = lib.mkForce true;
        ProtectKernelLogs = lib.mkForce false;
        ProtectKernelModules = lib.mkForce false;
        ProtectKernelTunables = lib.mkForce false;
        LockPersonality = lib.mkForce true;
        PrivateTmp = lib.mkForce false;
        # needed for hardware accelaration
        PrivateDevices = lib.mkForce false;
        PrivateUsers = lib.mkForce true;
        RemoveIPC = lib.mkForce true;

        SystemCallFilter = lib.mkForce [
          "~@clock"
          "~@aio"
          "~@chown"
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@memlock"
          "~@module"
          "~@mount"
          "~@obsolete"
          "~@privileged"
          "~@raw-io"
          "~@reboot"
          "~@setuid"
          "~@swap"
        ];
        SystemCallErrorNumber = lib.mkForce "EPERM";
      };
    };
}
