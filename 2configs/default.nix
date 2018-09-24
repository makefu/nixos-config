{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  imports = [
    {
      users.users =
        mapAttrs (_: h: { hashedPassword = h; })
                 (import <secrets/hashedPasswords.nix>);
    }
    ./editor/vim.nix
    ./binary-cache/nixos.nix
    ./minimal.nix
  ];

  # users are super important
  users.users = {
    root = {
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
    };
    makefu = {
      uid = 9001;
      group = "users";
      home = "/home/makefu";
      createHome = true;
      useDefaultShell = true;
      extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
    };
  };

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfreePredicate =  (pkg: pkgs.lib.hasPrefix "unrar-" pkg.name);
  krebs = {
    enable = true;

    dns.providers.lan  = "hosts";
    search-domain = "r";
    build.user = config.krebs.users.makefu;
  };




  boot.tmpOnTmpfs = true;
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root - -"
  ];

  environment.systemPackages = with pkgs; [
      jq
      git
      gnumake
      rxvt_unicode.terminfo
      htop
  ];

  programs.bash.enableCompletion = true;

  environment.shellAliases = {
    # TODO: see .aliases
    lsl = "ls -lAtr";
    dmesg = "journalctl -kb | cat";
    psg = "ps -ef | grep";
    nmap = "nmap -oN $HOME/loot/scan-`date +\%s`.nmap -oX $HOME/loot/scan-`date +%s`.xml";
    grep = "grep --color=auto";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    nano = pkgs.runCommand "empty" {} "mkdir -p $out";
    tinc = pkgs.tinc_pre;
  };


  nix.extraOptions = ''
    auto-optimise-store = true
  '';

  security.wrappers.sendmail = {
    source = "${pkgs.exim}/bin/sendmail";
    setuid = true;
  };
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=128M
    '';

}
