{
  home-manager.users.makefu.programs.atuin = {
    enable = true;
    settings = {
      auto_sync = true;
      sync_address = "https://atuin.euer.krebsco.de";
      search_mode = "prefix";
      # fuzzy,fulltext
      update_check = false;
      # filter_mode = "host";
      filter_mode = "global";
      # workspaces = true;
      style = "compact";
    };
  };
}
