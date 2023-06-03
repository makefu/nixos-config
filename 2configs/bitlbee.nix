{pkgs, ... }:
{
   services.bitlbee = {
    enable = true;
    # libpurple_plugins = [ pkgs.telegram-purple pkgs.pidgin-skypeweb];
    plugins = [ pkgs.bitlbee-mastodon ];
  };
  users.users.makefu.packages = with pkgs; [ weechat tmux ];
  state = [ "/var/lib/bitlbee" ];
}
