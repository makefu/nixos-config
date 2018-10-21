{ pkgs, lib, ... }:
{
  users.users.makefu = {
    extraGroups = [ "networkmanager" ];
    packages = with pkgs;[
      networkmanagerapplet
      gnome3.gnome_keyring gnome3.dconf
    ];
  };
  networking.wireless.enable = lib.mkForce false;

  systemd.services.modemmanager = {
    description = "ModemManager";
    bindsTo = [ "network-manager.service" ];
    wantedBy = [ "network-manager.service" "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.modemmanager}/bin/ModemManager";
      PrivateTmp = true;
      Restart = "always";
      RestartSec = "5";
    };
  };
  networking.networkmanager.enable = true;

# nixOSUnstable
  networking.networkmanager.wifi = {
    powersave = true;
    scanRandMacAddress = true;
  };
  state = [
    "/etc/NetworkManager/system-connections"  #NM stateful config files
  ];
}
