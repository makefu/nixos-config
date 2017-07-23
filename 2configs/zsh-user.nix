{ config, lib, pkgs, ... }:
##
with import <stockholm/lib>;
let
  mainUser = config.krebs.build.user.name;
in
{
  users.extraUsers.${mainUser}.shell = "/run/current-system/sw/bin/zsh";
  programs.zsh= {
    enable = true;
    enableCompletion = false ; #manually at the end
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
      LS_COLORS=$LS_COLORS:'di=1;31:' ; export LS_COLORS

      unset SSH_AGENT_PID
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"

      # fzf
      __fsel_fzf() {
        local cmd="''${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
          -o -type f -print \
          -o -type d -print \
          -o -type l -print 2> /dev/null | cut -b3-"}"
        setopt localoptions pipefail 2> /dev/null
        eval "$cmd" | FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
          echo -n "''${(q)item} "
        done
        local ret=$?
        echo
        return $ret
      }

      __fzf_use_tmux__() {
        [ -n "$TMUX_PANE" ] && [ "''${FZF_TMUX:-0}" != 0 ] && [ ''${LINES:-40} -gt 15 ]
      }

      __fzfcmd() {
        __fzf_use_tmux__ &&
          echo "fzf-tmux -d''${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
      }

      fzf-file-widget() {
        LBUFFER="''${LBUFFER}$(__fsel_fzf)"
        local ret=$?
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return $ret
      }
      zle     -N   fzf-file-widget
      bindkey '^T' fzf-file-widget

      # Auto-Completion
      for p in ''${(z)NIX_PROFILES}; do
        fpath+=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions)
      done
      autoload -U compinit && compinit
      compdef _pass brain
      zstyle ':completion::complete:brain::' prefix "$HOME/brain"
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

  krebs.per-user.${mainUser}.packages = [
    pkgs.nix-zsh-completions
    pkgs.fzf
  ];
}
