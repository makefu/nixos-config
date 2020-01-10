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

# nixOSUnstable
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi = {
    powersave = true;
    scanRandMacAddress = true;
    backend = "iwd";
  };
  services.gnome3.gnome-keyring.enable = true;
  networking.wireless.iwd.enable = true;

  state = [
    "/etc/NetworkManager/system-connections"  #NM stateful config files
  ];
  networking.networkmanager.dispatcherScripts = [
    { source = "${pkgs.prison-break}/bin/prison-break"; }
  ];
}
