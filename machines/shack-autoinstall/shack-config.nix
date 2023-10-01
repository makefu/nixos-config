{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # TODO:
  ];

  # shacks-specific
  networking.wireless = {
    enable = true;
    networks.shack.psk = "181471eb97eb23f12c6871227bc4a7b13c8f6af56dcc0d0e8b71f4d7a510cb4e";
  };
  networking.hostName = "shackbook";

  boot.tmpOnTmpfs = true;

  users.users.shack = {
    createHome = true;
    useDefaultShell = true;
    home = "/home/shack";
    uid = 9001;
    packages = with pkgs;[
      chromium
      firefox
    ];
    extraGroups = [ "audio" "wheel"  ];
    hashedPassword = "$6$KIxlQTLEnKl7cwC$LrmbwZ64Mlm7zqUUZ0EObPJMES3C0mQ6Sw7ynTuXzUo7d9EWg/k5XCGkDHMFvL/Pz19Awcv0knHB1j3dHT6fh/" ;
  };

  environment.variables = let
    ca-bundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  in {
    EDITOR = lib.mkForce "vim";
    CURL_CA_BUNDLE = ca-bundle;
    GIT_SSL_CAINFO = ca-bundle;
    SSL_CERT_FILE  = ca-bundle;
  };

  services.printing = {
    enable = true;
    # TODO: shack-printer
  };


  environment.systemPackages = with pkgs;[
    parted
    ddrescue
    tmux
    jq git gnumake htop rxvt_unicode.terminfo
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
      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
      vimrcConfig.vam.pluginDictionaries = [
        { names = [ "undotree" ]; }
        # vim-nix handles indentation better but does not perform sanity
        { names = [ "vim-addon-nix" ]; ft_regex = "^nix\$"; }
      ];
    })

  ];
  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
      HISTCONTROL='erasedups:ignorespace'
      HISTSIZE=900001
      HISTFILESIZE=$HISTSIZE
      shopt -s checkhash
      shopt -s histappend histreedit histverify
      shopt -s no_empty_cmd_completion
      PS1='\[\e[1;32m\]\w\[\e[0m\] '
    '';
  };

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=128M
  '';
  nix = {
    package = pkgs.nixUnstable;
    optimise.automatic = true;
    useSandbox = true;
    gc.automatic = true;
  };

  system.autoUpgrade.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];


  # gui and stuff
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [ pkgs.terminus_font ];
  };

  time.timeZone = "Europe/Berlin";
  services.timesyncd.enable = true;


  # GUI
  hardware.pulseaudio.enable = true;
  services.xserver = {
    enable = true;
    displayManager.auto.enable = true;
    displayManager.auto.user = "shack";

    desktopManager.xfce.enable = true;

    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "ctrl:nocaps, eurosign:e";
  };

  services.openssh = {
    enable = true;
    hostKeys = [
      { bits = 8192; type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
    ];
  };
}
