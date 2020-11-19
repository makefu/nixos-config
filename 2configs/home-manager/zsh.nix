{ pkgs, ... }:
{
  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  imports = [
    { #direnv
      home-manager.users.makefu.home.packages = [
        (pkgs.writers.writeDashBin "privatefox" "exec firefox -P Privatefox")
        pkgs.direnv pkgs.nur.repos.kalbasit.nixify ];
        # home-manager.users.makefu.home.file.".direnvrc".text = '''';
    }
    { # bat
      home-manager.users.makefu.home.packages = [ pkgs.bat ];
      home-manager.users.makefu.programs.zsh.shellAliases = {
        cat = "bat --style=header,snip";
        mirage = "sxiv"; # only available when tools/extra-gui is in use
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
      # navi package does not come with the navi.plugin.zsh anymore so we use .src
      initExtra = ''
        bindkey -e
        # shift-tab
        bindkey '^[[Z' reverse-menu-complete
        bindkey "\e[3~" delete-char
        zstyle ':completion:*' menu select

        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_IGNORE_SPACE
        setopt HIST_FIND_NO_DUPS

        compdef _pass brain
        zstyle ':completion::complete:brain::' prefix "$HOME/brain"
        compdef _pass secrets
        zstyle ':completion::complete:secrets::' prefix "$HOME/.secrets-pass/"
        
        # navi
        . ${pkgs.navi.src}/shell/navi.plugin.zsh
        # ctrl-x ctrl-e
        autoload -U compinit && compinit
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey '^xe' edit-command-line
        bindkey '^x^e' edit-command-line
      '';
    };
  };
}
