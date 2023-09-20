{ pkgs, lib, ... }:
{
  users.users.makefu = {
    extraGroups = [ "networkmanager" ];
    packages = with pkgs;[
      networkmanagerapplet
      gnome3.gnome-keyring dconf
    ];
  };
  networking.wireless.enable = lib.mkForce false;

  systemd.services.modemmanager = {
    description = "ModemManager";
    bindsTo = [ "NetworkManager.service" ];
    wantedBy = [ "NetworkManager.service" "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.modemmanager}/bin/ModemManager";
      PrivateTmp = true;
      Restart = "always";
      RestartSec = "5";
    };
  };

# nixOSUnstable
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi = {
    powersave = true;
    scanRandMacAddress = true;
    backend = "iwd";
  };
  services.gnome.gnome-keyring.enable = true;
  networking.wireless.iwd.enable = true;

  state = [
    "/etc/NetworkManager/system-connections"  #NM stateful config files
  ];
  networking.networkmanager.dispatcherScripts = [
    { source = "${pkgs.prison-break}/bin/prison-break"; }
  ];

  # TODO: not sure if this actually works
  systemd.services.NetworkManager-dispatcher.environment = {
    DISPLAY= ":0";
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/9001/bus";
  };

}
