{ config, lib, ... }:
{
  krebs.exim-retiolum.enable = lib.mkDefault true;
  services.smartd = {
    enable = true;
    notifications = {
      mail = {
        enable = true;
        recipient = config.krebs.users.makefu.mail;
      };
    };
    # short daily, long weekly, check on boot
    defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04)";

    devices = lib.mkDefault [ ];
  };
}
