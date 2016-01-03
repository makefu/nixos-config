{ config, lib, pkgs, ... }:

with lib;
{
  system.stateVersion = "15.09";

  imports = [
    {
      users.extraUsers =
        mapAttrs (_: h: { hashedPassword = h; })
                 (import <secrets/hashedPasswords.nix>);
    }
    ./vim.nix
  ];


  krebs = {
    enable = true;
    search-domain = "retiolum";
    build =  {
      target = mkDefault "root@${config.krebs.build.host.name}";
      user = config.krebs.users.makefu;
      source = {
        git.nixpkgs = {
          #url = https://github.com/NixOS/nixpkgs;
          url = mkDefault https://github.com/nixos/nixpkgs;
          rev = mkDefault "93d8671e2c6d1d25f126ed30e5e6f16764330119"; # unstable @ 2015-01-03, tested on filepimp
          target-path = "/var/src/nixpkgs";
        };

        dir.secrets = {
          host = config.krebs.hosts.pornocauster;
          path = "/home/makefu/secrets/${config.krebs.build.host.name}/";
        };

        dir.stockholm = {
          host = config.krebs.hosts.pornocauster;
          path = "/home/makefu/stockholm" ;
          target-path = "/var/src/stockholm";
        };
      };
    };
  };

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

  networking.hostName = config.krebs.build.host.name;
  nix.maxJobs = config.krebs.build.host.cores;

  time.timeZone = "Europe/Berlin";
  #nix.maxJobs = 1;

  programs.ssh.startAgent = false;
  services.openssh.enable = true;
  nix.useChroot = true;

  users.mutableUsers = false;

  boot.tmpOnTmpfs = true;

  networking.firewall.rejectPackets = true;
  networking.firewall.allowPing = true;

  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root - -"
  ];

  environment.variables = {
    NIX_PATH = with config.krebs.build.source; with dir; with git;
      mkForce (concatStringsSep ":" [
        "nixpkgs=${nixpkgs.target-path}"
        "${nixpkgs.target-path}"
      ]);
    EDITOR = mkForce "vim";
  };

  environment.systemPackages = with pkgs; [
      jq
      git
      gnumake
      rxvt_unicode.terminfo
      htop
  ];

  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
      HISTCONTROL='erasedups:ignorespace'
      HISTSIZE=900001
      HISTFILESIZE=$HISTSIZE

      PYTHONSTARTUP="~/.pythonrc";

      shopt -s checkhash
      shopt -s histappend histreedit histverify
      shopt -s no_empty_cmd_completion
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
    psg = "ps -ef | grep";
    nmap = "nmap -oN $HOME/loot/scan-`date +\%s`.nmap -oX $HOME/loot/scan-`date +%s`.xml";
    grep = "grep --color=auto";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    nano = pkgs.runCommand "empty" {} "mkdir -p $out";
  };

  services.cron.enable = false;
  services.nscd.enable = false;
  services.ntp.enable = false;
  services.timesyncd.enable = true;
  services.ntp.servers = [
    "pool.ntp.org"
    "time.windows.com"
    "time.apple.com"
    "time.nist.gov"
  ];

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
