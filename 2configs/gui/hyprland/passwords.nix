{ pkgs, config, ... }: 
let
    mainUser = config.krebs.build.user.name;
    share = "/home/makefu/.local/share";
in {
  home-manager.users.${mainUser} = {
    # disable standalone ssh-agent; gnome-keyring provides SSH agent functionality
    services.ssh-agent.enable = false;
    programs.rbw = {
      enable = true;
      settings.base_url = "bw.euer.krebsco.de";
      settings.email = "makefu@x";
    };
    # start gnome-keyring-daemon with SSH component and propagate SSH_AUTH_SOCK
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"
      ];
      env = [
        "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/keyring/ssh"
      ];
    };
  };

  state = map (x: "${share}/${x}" ) [
    "keyrings"
    "atuin"
    "gvfs-metadata"
    "dolphin"
    "user-places.xbel"
    "recently-used.xbel"
  ];
  services.gnome.gnome-keyring.enable = true;
  # must be set to the greeter in use
  security.pam.services.sddm.enableGnomeKeyring = true;
  # unlock gnome-keyring when resuming from hyprlock
  security.pam.services.hyprlock.enableGnomeKeyring = true;
  environment.systemPackages = [pkgs.libsecret];
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";
}
