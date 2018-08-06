{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    taskwarrior
    pass
    gopass
    mutt
    weechat
    tmux
  ];

}
