{pkgs, ... }:
# state: /var/lib/bitlbee
{
   services.bitlbee = {
    enable = true;
    libpurple_plugins = [ pkgs.telegram-purple pkgs.pidgin-skypeweb];
  };
}
