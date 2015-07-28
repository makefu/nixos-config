{ config, lib, pkgs, ... }:

with lib;
{
  imports = [ ];
  krebs.enable = true;
  krebs.search-domain = "retiolum";

  networking.hostName = config.krebs.build.host.name;
  users.extraUsers = {
    root = {
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
    };
    makefu = {
      uid = 9001;
      group = "users";
      home = "/home/makefu";
      createHome = true;
      useDefaultShell = true;
      extraGroups = [
        "wheel"
      ];
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
    };
  };

  services.openssh.enable = true;
  nix.useChroot = true;

  users.mutableUsers = true;

  boot.tmpOnTmpfs = true;
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root - -"
  ];

  environment.extraInit = ''
    EDITOR=vim
    '';

  environment.systemPackages = with pkgs; [
      git
      vim
      gnumake
      rxvt_unicode.terminfo
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
      complete -d cd
      '';

    promptInit = ''
      case $UID in
         0) PS1='\[\e[1;31m\]\w\[\e[0m\] ' ;;
      9001) PS1='\[\e[1;32m\]\w\[\e[0m\] ' ;;
         *) PS1='\[\e[1;35m\]\u \[\e[1;32m\]\w\[\e[0m\] ' ;;
      esac
      if test -n "$SSH_CLIENT"; then
        PS1='\[\033[35m\]\h'" $PS1"
      fi
      '';
  };

  environment.shellAliases = {
    lsl = "ls -lAtr";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    nano = pkgs.runCommand "empty" {} "mkdir -p $out";
  };

  services.cron.enable = false;
  services.nscd.enable = false;

  security.setuidPrograms = [ "sendmail" ];
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=128M
    '';
  # Enable IPv6 Privacy Extensions
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.use_tempaddr" = 2;
    "net.ipv6.conf.default.use_tempaddr" = 2;
  };

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
}
