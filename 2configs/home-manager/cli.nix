{
  home-manager.users.makefu = {
    services.gpg-agent = {
      defaultCacheTtl = 900;
      maxCacheTtl = 7200;
      defaultCacheTtlSsh = 3600;
      maxCacheTtlSsh = 86400;
      enableSshSupport = true;
    };
    programs.fzf.enable = true; # alt-c
  };
}
