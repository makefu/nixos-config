{ pkgs, ... }:
{
  imports = [
    { #direnv
      home-manager.users.makefu.home.packages = [ pkgs.direnv ];
      home-manager.users.makefu.home.file.".direnvrc".text = ''
      use_nix() {
        local path="$(nix-instantiate --find-file nixpkgs)"

        if [ -f "$${path}/.version-suffix" ]; then
          local version="$(< $path/.version-suffix)"
        elif [ -f "$path/.version" ]; then
          local version="$(< $path/.version)"
        else
          local version="$(< $(< $path/.git/HEAD))"
        fi

        local cache=".direnv/cache-''${version:-unknown}"

        if [[ ! -e "$cache" ]] || \
          [[ "$HOME/.direnvrc" -nt "$cache" ]] || \
          [[ .envrc -nt "$cache" ]] || \
          [[ default.nix -nt "$cache" ]] || \
          [[ shell.nix -nt "$cache" ]];
        then
          [ -d .direnv ] || mkdir .direnv
          local tmp=$(nix-shell --show-trace "$@" \
            --run "\"$direnv\" dump zsh")
          echo "$tmp" > "$cache"
        fi

        local path_backup=$PATH term_backup=$TERM
        . "$cache"

        export PATH=$PATH:$path_backup TERM=$term_backup

        if [[ $# = 0 ]]; then
          watch_file default.nix
          watch_file shell.nix
        fi
      }
      '';
      home-manager.users.makefu.programs.zsh.initExtra = ''
      nixify() {
        if [ ! -e ./.envrc ]; then
          echo "use nix" > .envrc
          direnv allow
        fi
        if [ ! -e default.nix ]; then
          cat > default.nix <<'EOF'
      with import <nixpkgs> {};
      stdenv.mkDerivation {
        name = "env";
        buildInputs = [
          bashInteractive
        ];
      }
      EOF
          ''${EDITOR:-vim} default.nix
        fi
      }
      eval "$(direnv hook zsh)"
      '';
    }
    { # bat
    home-manager.users.makefu.home.packages = [ pkgs.bat ];
      home-manager.users.makefu.programs.zsh.shellAliases = {
        cat = "bat";
        catn = "${pkgs.coreutils}/bin/cat";
        ncat = "${pkgs.coreutils}/bin/cat";
      };
    }
  ];
  environment.pathsToLink = [ "/share/zsh" ];
  home-manager.users.makefu = {
    programs.fzf.enable = false; # alt-c
    programs.zsh = {
      enable = true;
      enableAutosuggestions = false;
      enableCompletion = true;
      oh-my-zsh.enable = false;
      history = {
        size = 900001;
        save = 900001;
        ignoreDups = true;
        extended = true;
        share = true;
      };
      sessionVariables = {
        # TERM = "rxvt-unicode-256color";
        TERM = "xterm";
        LANG = "en_US.UTF8";
        LS_COLORS = ":di=1;31:";
        EDITOR = "vim";
      };
      shellAliases = {
        lsl = "ls -lAtr";
        t = "task";
        xo = "mimeopen";
        nmap = "nmap -oN $HOME/loot/scan-`date +\%s`.nmap -oX $HOME/loot/scan-`date +%s`.xml";
      };
      initExtra = ''
        bindkey -e
        # shift-tab
        bindkey '^[[Z' reverse-menu-complete
        bindkey "\e[3~" delete-char
        zstyle ':completion:*' menu select

        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_IGNORE_SPACE
        setopt HIST_FIND_NO_DUPS

        unset SSH_AGENT_PID
        export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
        compdef _pass brain
        zstyle ':completion::complete:brain::' prefix "$HOME/brain"
        compdef _pass secrets
        zstyle ':completion::complete:secrets::' prefix "$HOME/.secrets-pass/"

        # ctrl-x ctrl-e
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey '^xe' edit-command-line
        bindkey '^x^e' edit-command-line
      '';
    };
  };
}
