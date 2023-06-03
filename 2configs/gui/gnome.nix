{ config, lib, pkgs, ... }:

let
  mainUser = config.krebs.build.user.name;
in
{
  programs.gnome-terminal.enable = true;
  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    #displayManager.autoLogin = {
    #  enable = true;
    #  user = mainUser;
    #};
  };
  programs.dconf.enable = true;
  home-manager.users.${mainUser}.dconf = {
    enable = true;
    settings = {
      "org/gnome/terminal/legacy" = {
        mnemonics-enabled = false;
        theme-variant = "dark";
      };
      "org/gnome/desktop/interface" = {
        enable-animations = false;
        enable-hot-corners = false;
        show-battery-percentage = true;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        edge-scrolling-enabled = false;
        natural-scroll = false;
        send-events = "enabled";
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/session".idle-delay = 900;
      "org/gnome/desktop/wm/keybindings" = {
        close=["<Shift><Super>c"];
        minimize=["<Super>n"];
        move-to-workspace-1=["<Shift><Super>1"];
        move-to-workspace-2=["<Shift><Super>2"];
        move-to-workspace-3=["<Shift><Super>3"];
        move-to-workspace-4=["<Shift><Super>4"];
        panel-run-dialog=["<Super>r"];
        switch-to-workspace-1=["<Super>1"];
        switch-to-workspace-2=["<Super>2"];
        switch-to-workspace-3=["<Super>3"];
        switch-to-workspace-4=["<Super>4"];
        toggle-fullscreen=["<Super>f"];
      };
      "org/gnome/desktop/wm/preferences".num-workspaces = 4;
      "org/gnome/settings-daemon/plugins/color".night-light-enabled = true;
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = "gnome-terminal";
        name = "terminal";
      };
    };
  };
}
