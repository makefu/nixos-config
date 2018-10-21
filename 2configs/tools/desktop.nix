{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    taskwarrior
    (pass.withExtensions (ext: [ ext.pass-otp ]))
    gopass
    mutt
    weechat
    tmux
  ];

}
