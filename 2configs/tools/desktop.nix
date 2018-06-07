{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    taskwarrior
    pass
    mutt
    weechat
    tmux
  ];
}
