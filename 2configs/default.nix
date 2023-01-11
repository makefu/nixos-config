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
    # ./security/hotfix.nix
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
      isNormalUser = true;
      useDefaultShell = true;
      extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
    };
  };
  nix.trustedUsers = [ config.krebs.build.user.name ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;

  nixpkgs.config.allowUnfreePredicate = pkg: packageName pkg == "unrar";

  krebs = {
    enable = true;

    dns.providers.lan  = "hosts";
    build.user = config.krebs.users.makefu;
  };


  boot.tmpOnTmpfs = true;

  environment.systemPackages = with pkgs; [
      jq
      git
      gnumake
      rxvt_unicode.terminfo
      htop
      nix-output-monitor
  ];

  programs.bash.enableCompletion = true;

  environment.shellAliases = {
    # TODO: see .aliases
    lsl = "ls -lAtr";
    ip = "ip -c -br";
    dmesg = "dmesg -L --reltime";
    psg = "ps -ef | grep";
    nmap = "nmap -oN $HOME/loot/scan-`date +\%s`.nmap -oX $HOME/loot/scan-`date +%s`.xml";
    grep = "grep --color=auto";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    #nano = pkgs.runCommand "empty" {} "mkdir -p $out";
    tinc = pkgs.tinc_pre;
  };


  nix.extraOptions = ''
    auto-optimise-store = true
  '';

  #security.wrappers.sendmail = {
  #  source = "${pkgs.exim}/bin/sendmail";
  #  setuid = true;
  #};
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=128M
    '';
  environment.pathsToLink = [ "/share" ];
  security.acme = {
    defaults.email = "letsencrypt@syntax-fehler.de";
    acceptTerms = true;
  };
  system.stateVersion = lib.mkDefault "20.03";
  services.postgresql.package = pkgs.postgresql_14;
}
