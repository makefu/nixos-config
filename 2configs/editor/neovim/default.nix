{pkgs, config,  ...}:
{
  fonts.fonts = [ pkgs.font-awesome_5 ];
  # Neovim dependencies
  home-manager.users.makefu = {
    home.packages = with pkgs; [
      ctags # dependencie
      jq # For fixing json files
      xxd # .bin files will be displayed with xxd
      shellcheck # Shell linting
      # ansible-lint # Ansible linting
      unzip # To vim into unzipped files
      # nodePackages.jsonlint # json linting
      #ccls # C/C++ language server
      #clang-tools # C++ fixer
      cargo

      # Go support
      #go
      #gotools
      #gocode
    ];

    home.file.".config/pycodestyle".text= ''
      [pycodestyle]
      max-line-length = 125
    '';
    programs.neovim = {
      enable = true;
      withPython3 = true;
      # withNodeJs = true;
      extraPython3Packages = (ps: with ps; [
        # python-language-server
        # pyls-mypy
        black libxml2
      ]);
      extraConfig = builtins.readFile ./vimrc;
      plugins = with pkgs.vimPlugins;[
        undotree
        vim-addon-nix

        nerdtree # file manager
        commentary # comment stuff out based on language
        fugitive # full git integration
        vim-airline-themes # lean & mean status/tabline
        vim-airline # status bar
        gitgutter # git diff in the gutter (sign column)
        vim-trailing-whitespace # trailing whitspaces in red
        tagbar # F3 function overview
        ReplaceWithRegister # For better copying/replacing
        polyglot # Language pack
        vim-indent-guides # for displaying indent levels
        deoplete-nvim # general autocompletion
        deoplete-go
        ale
        molokai # color scheme
      ];
    };
  };
}

