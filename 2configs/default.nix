{ config, lib, pkgs, ... }:

with config.krebs.lib;
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

  nixpkgs.config.allowUnfreePredicate =  (pkg: pkgs.lib.hasPrefix "unrar-" pkg.name);
  krebs = {
    enable = true;

    dns.providers.siem = "hosts";
    search-domain = "retiolum";
    build =  {
      user = config.krebs.users.makefu;
      source =  mapAttrs (_: mkDefault) {
        nixpkgs = {
          url = https://github.com/nixos/nixpkgs;
          rev = "0546a4a"; # stable @ 2016-06-11
        };
        secrets = if getEnv "dummy_secrets" == "true"
                  then toString <stockholm/makefu/6tests/data/secrets>
                  else "/home/makefu/secrets/${config.krebs.build.host.name}";
        stockholm = "/home/makefu/stockholm";

        # Defaults for all stockholm users?
        nixos-config = "symlink:stockholm/${config.krebs.build.user.name}/1systems/${config.krebs.build.host.name}.nix";
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

  programs.ssh = {
    startAgent = false;
  };
  services.openssh.enable = true;
  nix.useChroot = true;

  users.mutableUsers = false;

  boot.tmpOnTmpfs = true;

  networking.firewall.rejectPackets = true;
  networking.firewall.allowPing = true;

  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root - -"
  ];
  nix.nixPath = [ "/var/src" ];
  environment.variables = {
    NIX_PATH = mkForce "/var/src";
    EDITOR = mkForce "vim";
  };

  environment.systemPackages = with pkgs; [
      jq
      git
      get
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
    tinc = pkgs.tinc_pre;
    gnupg1compat = super.gnupg1compat.override { gnupg = self.gnupg21; };
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
  nix.extraOptions = ''
    auto-optimise-store = true
  '';

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

  system.activationScripts.nix-defexpr = ''
    (set -euf
     for i in /home/makefu /root/;do
       f="$i/.nix-defexpr"
       rm -fr "$f"
       ln -s /var/src/nixpkgs "$f"
     done)
  '';

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
}
