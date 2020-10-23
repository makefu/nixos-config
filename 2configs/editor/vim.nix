{ config, pkgs, ... }:

{

  environment.systemPackages = [
    pkgs.python27Full # required for youcompleteme
    (pkgs.vim_configurable.customize {
      name = "vim";

      vimrcConfig.customRC = builtins.readFile ./vimrc;
      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
      vimrcConfig.vam.pluginDictionaries = [
        { names = [ "undotree"
        "YouCompleteMe"
        #"UltiSnips"
          "vim-better-whitespace" ]; }
        # vim-nix handles indentation better but does not perform sanity
        { names = [ "vim-addon-nix" ]; ft_regex = "^nix\$"; }
      ];

    })
  ];
}
