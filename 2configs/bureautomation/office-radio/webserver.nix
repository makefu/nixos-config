{ pkgs, ... }:
let
  mpds = import ./mpdconfig.nix;
  pkg = pkgs.office-radio;
in {
  systemd.services.office-radio-appsrv = {
    after = [ "network.target" ];
    description = "Office Radio Appserver";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
        ExecStart = "${pkg}/bin/office-radio";
        DynamicUser = true;
        ProtectSystem = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
        RestrictNamespaces = true;
        Restart = "always";
    };
  };
  systemd.services.office-radio-stopper = {
    after = [ "network.target" ];
    description = "Office Radio Script to stop idle streams";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
        ExecStart = "${pkg}/bin/stop-idle-streams";
        DynamicUser = true;
        ProtectSystem = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
        RestrictNamespaces = true;
        Restart = "always";
    };
  };
}
