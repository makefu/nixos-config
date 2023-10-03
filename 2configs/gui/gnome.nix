{ config, lib, pkgs, ... }:

let
  mainUser = config.krebs.build.user.name;
in
{
  environment.systemPackages = with pkgs.gnomeExtensions; [
    tactile
    thinkpad-thermal
  ];
  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
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
      "org/gnome/shell/extensions/tactile" = {
        border-size = 0;
        monitor-0-layout=2;
        row-0=1;
      };
      "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        audible-bell=false;
        font="Terminus 12";
        scrollback-unlimited=true;
        use-system-font=false;
        use-theme-colors=true;
        visible-name = "default";
      };
      "org/gnome/shell/keybindings" = {
        switch-to-application-1=[];
        switch-to-application-2=[];
        switch-to-application-3=[];
        switch-to-application-4=[];
      };
      "org/gnome/shell" = {
        disable-user-extensions=false;
        enabled-extensions=[
          "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
          "thinkpadthermal@moonlight.drive.vk.gmail.com"
          "clipboard-indicator@tudmotu.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "places-menu@gnome-shell-extensions.gcampax.github.com"
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "unite@hardpixel.eu"
          "tactile@lundal.io"
        ];
        last-selected-power-profile="power-saver";

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
      "org/gnome/desktop/session".idle-delay = 900; # 15minutes screensaver
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
        #command = "gnome-terminal";
        #name = "terminal";
        command = "guake-toggle";
        name = "guake";
      };
      "apps/guake/style/font" = {
        style="Terminus 12";
      };
      "apps/guake/general" = {
        infinite-history = true;
        start-at-login = true;
      };

    };
  };
  services.dbus.packages = with pkgs; [ gnome2.GConf gnome3.gnome-settings-daemon ];
}
