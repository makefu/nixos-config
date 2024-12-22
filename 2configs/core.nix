{pkgs, lib, config, ... }:{
  # users are super important
  users.users = {
    root.openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
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
  # nix.settings.trusted-users = [ config.krebs.build.user.name ];
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  environment.systemPackages = with pkgs; [
      jq
      git
      gnumake
      rxvt-unicode-unwrapped.terminfo
      htop
  ];

  #programs.bash.completion.enable = true;

  environment.shellAliases = {
    # TODO: see .aliases
    lsl = "ls -lAtr";
    ip = "ip -c -br";
    dmesg = "dmesg -L --reltime";
    psg = "ps -ef | grep";
    nmap = "nmap -oN $HOME/loot/scan-`date +\%s`.nmap -oX $HOME/loot/scan-`date +%s`.xml";
    grep = "grep --color=auto";
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

  boot.kernel.sysctl."kernel.dmesg_restrict" = 0;
}
