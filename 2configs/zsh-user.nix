{ config, lib, pkgs, ... }:
##
with config.krebs.lib;
let
  mainUser = config.krebs.build.user.name;
in
{
  users.extraUsers.${mainUser}.shell = "/run/current-system/sw/bin/zsh";
  programs.zsh= {
    enable = true;
    interactiveShellInit = ''
      HISTSIZE=900001
      HISTFILESIZE=$HISTSIZE
      SAVEHIST=$HISTSIZE

      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_FIND_NO_DUPS
      bindkey -e
      # shift-tab
      bindkey '^[[Z' reverse-menu-complete
      bindkey "\e[3~" delete-char
      zstyle ':completion:*' menu select

      ${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye >/dev/null
      GPG_TTY=$(tty)
      export GPG_TTY
      unset SSH_AGENT_PID
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
      '';

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
}
