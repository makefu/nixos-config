{ config, pkgs, ... }:

{

  environment.systemPackages = [
    ((pkgs.vim_configurable).customize {
      name = "vim";
      vimrcConfig.customRC = builtins.readFile ./vimrc;
      vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; { start = [
       "undotree"
        "YouCompleteMe"
        #"UltiSnips"
        # vim-nix handles indentation better but does not perform sanity
          "vim-nix"
          "vim-addon-nix"
          "vim-better-whitespace"
      ];
      };
    })
  ];
}
