{ pkgs, config, ... }: 
let
  mainUser = config.krebs.build.user.name;
in {
  # Terminal
  home-manager.users.${mainUser} = {
    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.terminus_font;
        name = "Terminus";
        size = 12;
      };
      keybindings = {
        "shift+insert" = "paste_from_clipboard";
        "ctrl+c" = "copy_or_interrupt";
      };
      settings = {
        update_check_interval = 0;
        enable_audio_bell = false;
        scollback_lines = 100000;
        confirm_os_window_close = 0;
        copy_on_select = "yes";
      };
    };
  };
}
