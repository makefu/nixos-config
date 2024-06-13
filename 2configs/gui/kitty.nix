{
  # Terminal
  home-manager.users.makefu = {
    programs.kitty = {
      enable = true;
      font.package = pkgs.terminus_font;
      settings = {
        update_check_interval = 0;
        enable_audio_bell = false;
        scollback_lines = 100000;
        confirm_os_window_close = 0;
      };
    };
  };
}
