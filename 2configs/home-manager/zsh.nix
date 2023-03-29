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
    { 
      home-manager.users.makefu.home.packages = [
        (pkgs.writers.writeDashBin "privatefox" "exec firefox -P Privatefox")
      ];
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
  environment.pathsToLink = [
    "/share/zsh"
  ];

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  home-manager.users.makefu = {

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.direnv.enableZshIntegration = true;
    home.packages = [ (pkgs.writeDashBin "nixify" ''
test ! -e shell.nix && cat > shell.nix <<EOF
{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = [ pkgs.hello ];
}
EOF
echo "use nix" >> .envrc
direnv allow
'')
    ];
    #home.packages = [ pkgs.direnv pkgs.nix-direnv ];

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
        ignoreSpace = true;

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
      #zplug = {
      #  enable = true;
      #  plugins = [
      #    { name = "denisidoro/navi" ; }
      #    { name = "zsh-users/zsh-autosuggestions" ; }
      #  ];
      #};
      initExtra = ''
        bindkey -e
        zle -N edit-command-line
        # ctrl-x ctrl-e
        bindkey '^xe' edit-command-line
        bindkey '^x^e' edit-command-line
        # shift-tab
        bindkey '^[[Z' reverse-menu-complete
        bindkey "\e[3~" delete-char
        zstyle ':completion:*' menu select

        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_FIND_NO_DUPS

        compdef _pass brain
        zstyle ':completion::complete:brain::' prefix "$HOME/brain"

        compdef _pass secrets
        zstyle ':completion::complete:secrets::' prefix "$HOME/.secrets-pass/"
      '';
    };
  };
}
