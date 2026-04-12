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
        #"ctrl+c" = "copy_or_interrupt";
        "ctrl+shift+r" = "clear_terminal reset active 🍎";
      };
      settings = {
        update_check_interval = 0;
        enable_audio_bell = false;
        scollback_lines = 100000;
        confirm_os_window_close = 0;
        copy_on_select = "yes";
        

        # workmux config
        # REQUIRED: Enable remote control
        allow_remote_control  = "yes";

        # REQUIRED: Set up socket for remote control
        # The socket path can be customized, but using kitty_pid ensures uniqueness
        "listen_on" = "unix:/home/makefu/kitty-{kitty_pid}.sock";

        # RECOMMENDED: Enable splits layout for pane splitting
        enabled_layouts = "splits,stack";

        # status view
        tab_title_template = "{title}{custom}";
        watcher = "workmux_watcher.py"; # TODO: living in ~/.config/kitty/workmux_watcher.py
      };
    };
  };
}
