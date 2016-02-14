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

      # load gpg-agent
      envfile="$HOME/.gnupg/gpg-agent.env"
      if [ -e "$envfile" ] && kill -0 $(grep GPG_AGENT_INFO "$envfile" | cut -d: -f 2) 2>/dev/null; then
        eval "$(cat "$envfile")"
      else
        eval "$(${pkgs.gnupg}/bin/gpg-agent --daemon --enable-ssh-support --write-env-file "$envfile")"
      fi
      export GPG_AGENT_INFO
      export SSH_AUTH_SOCK
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
