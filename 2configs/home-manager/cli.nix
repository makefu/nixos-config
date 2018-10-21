{pkgs, ... }: {
  home-manager.users.makefu = {
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 900;
      maxCacheTtl = 7200;
      defaultCacheTtlSsh = 3600;
      maxCacheTtlSsh = 86400;
      enableSshSupport = true;
      enableScDaemon = true;
    };
    programs.fzf.enable = true; # alt-c
  };
  services.udev.packages = [
    pkgs.libu2f-host
    pkgs.yubikey-personalization
  ];
}
