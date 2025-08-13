{inputs,...}:
(inputs.nixvim.legacyPackages.${system}.makeNixvim {
  vimAlias = true;
  colorscheme = "molokai";
  opts = {
    expandtab = true;
    laststatus=2:
    modeline=true;
    modelines=10;
    title=true
    pastetoggle="<F2>";
    showmode = true;

    number = true;
    undofile = true;
    undolevels = 10000;
    undoreload = 10000;
  };
  extraVimConfig = ''
  '';
})
