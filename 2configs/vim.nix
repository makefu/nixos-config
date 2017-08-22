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

    vimrcConfig.customRC = ''
      set nocompatible
      syntax on
      set list
      set listchars=tab:▸\ 
      "set list listchars=tab:>-,trail:.,extends:>

      filetype off
      filetype plugin indent on

      colorscheme darkblue
      set background=dark

      set number
      set relativenumber
      set mouse=a
      set ignorecase
      set incsearch
      set wildignore=*.o,*.obj,*.bak,*.exe,*.os
      set textwidth=79
      set shiftwidth=2
      set expandtab
      set softtabstop=2
      set shiftround
      set smarttab
      set tabstop=2
      set et
      set autoindent
      set backspace=indent,eol,start


      inoremap <F1> <ESC>
      nnoremap <F1> <ESC>
      vnoremap <F1> <ESC>

      nnoremap <F5> :UndotreeToggle<CR>
      set undodir  =~/.vim/undo
      set undofile
      "maximum number of changes that can be undone
      set undolevels=1000000
      "maximum number lines to save for undo on a buffer reload
      set undoreload=10000000

      nnoremap <F2> :set invpaste paste?<CR>
      set pastetoggle=<F2>
      set showmode

      set showmatch
      set matchtime=3
      set hlsearch

      autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red


      " save on focus lost
      au FocusLost * :wa

      autocmd BufRead *.json set filetype=json
      au  BufNewFile,BufRead *.mustache set syntax=mustache

      cnoremap SudoWrite w !sudo tee > /dev/null %

      " create Backup/tmp/undo dirs
      set backupdir=~/.vim/backup
      set directory=~/.vim/tmp

      function! InitBackupDir()
        let l:parent = $HOME    . '/.vim/'
        let l:backup = l:parent . 'backup/'
        let l:tmpdir = l:parent . 'tmp/'
        let l:undodir= l:parent . 'undo/'


        if !isdirectory(l:parent)
          call mkdir(l:parent)
        endif
        if !isdirectory(l:backup)
          call mkdir(l:backup)
        endif
        if !isdirectory(l:tmpdir)
          call mkdir(l:tmpdir)
        endif
        if !isdirectory(l:undodir)
          call mkdir(l:undodir)
        endif
      endfunction
      call InitBackupDir()

      augroup Binary
        " edit binaries in xxd-output, xxd is part of vim
        au!
        au BufReadPre  *.bin let &bin=1
        au BufReadPost *.bin if &bin | %!xxd
        au BufReadPost *.bin set ft=xxd | endif
        au BufWritePre *.bin if &bin | %!xxd -r
        au BufWritePre *.bin endif
        au BufWritePost *.bin if &bin | %!xxd
        au BufWritePost *.bin set nomod | endif
      augroup END



    '';

      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins // customPlugins;
      vimrcConfig.vam.pluginDictionaries = [
        { names = [ "undotree"
          # "YouCompleteMe"
          "vim-better-whitespace" ]; }
        { names = [ "vim-addon-nix" ]; ft_regex = "^nix\$"; }
      ];

    })
  ];
}
