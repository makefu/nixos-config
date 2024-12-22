{
  home-manager.users.makefu.programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    daemon.enable = true;
    settings = {
      auto_sync = true;
      sync_address = "https://atuin.euer.krebsco.de";
      search_mode = "fulltext";
      # fuzzy,fulltext,prefix
      update_check = false;
      # filter_mode = "host";
      filter_mode = "global";
      # workspaces = true;
      style = "compact";
    };
  };
}
