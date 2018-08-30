{ config, pkgs, ... }:

let
  customPlugins.vim-better-whitespace = pkgs.vimUtils.buildVimPlugin {
    name = "vim-better-whitespace";
    src = pkgs.fetchFromGitHub {
      owner = "ntpeters";
      repo = "vim-better-whitespace";
      rev = "984c8da518799a6bfb8214e1acdcfd10f5f1eed7";
      sha256 = "10l01a8xaivz6n01x6hzfx7gd0igd0wcf9ril0sllqzbq7yx2bbk";
    };
  };

in {

  environment.systemPackages = [
    pkgs.python27Full # required for youcompleteme
    (pkgs.vim_configurable.customize {
      name = "vim";

      vimrcConfig.customRC = builtins.readFile ./vimrc;
      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins // customPlugins;
      vimrcConfig.vam.pluginDictionaries = [
        { names = [ "undotree"
          # "YouCompleteMe"
          "vim-better-whitespace" ]; }
        # vim-nix handles indentation better but does not perform sanity
        { names = [ "vim-addon-nix" ]; ft_regex = "^nix\$"; }
      ];

    })
  ];
}
