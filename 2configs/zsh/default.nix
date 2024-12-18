{ config, lib, pkgs, ... }:
let
  mainUser = config.krebs.build.user.name;
in
{
  programs.zsh= {
    enable = true;
    enableCompletion = false; #manually at the end

    promptInit = ''
      RPROMPT=""
      autoload colors && colors
      case $UID in
         0) PROMPT="%{$fg[red]%}%~%{$reset_color%} " ;;
      9001) PROMPT="%{$fg[green]%}%~%{$reset_color%} " ;;
         *) PROMPT="%{$fg[yellow]%}%n %{$fg[green]%}%~%{$reset_color%} " ;;
      esac
      if test -n "$SSH_CLIENT"; then
        PROMPT="%{$fg[magenta]%}%m $PROMPT"
      fi
      '';
  };

  users.users.${mainUser} = {
    shell = "/run/current-system/sw/bin/zsh";
    packages = [ pkgs.nix-zsh-completions ];
  };
}
