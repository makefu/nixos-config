{ pkgs, config, ... }: 
let
    mainUser = config.krebs.build.user.name;
    share = "/home/makefu/.local/share";
in {
  home-manager.users.${mainUser} = {
    # disable standalone ssh-agent; gnome-keyring provides SSH agent functionality
    # services.ssh-agent.enable = false;
    # services.gnome-keyring.enable = true; # use nixos module below
    home.packages = with pkgs;[ gcr gnome-keyring libsecret];
    programs.rbw = {
      enable = true;
      settings.base_url = "bw.euer.krebsco.de";
      settings.identity_url = "bw.euer.krebsco.de";
      settings.email = "makefu@syntax-fehler.de";
    };
    # start gnome-keyring-daemon with SSH component and propagate SSH_AUTH_SOCK
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"
        "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets"
      ];

      env = [
          # Do NOT set SSH_AUTH_SOCK manually — gcr-ssh-agent sets it via systemd/xdg
          # "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/keyring/ssh"
          "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/gcr/ssh"
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
  services.dbus.packages = [ pkgs.gnome-keyring pkgs.gcr ];
  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;

  services.gnome.gcr-ssh-agent.enable = true;
  # must be set to the greeter in use
  security.pam.services.sddm.enableGnomeKeyring = true;
  # unlock gnome-keyring when resuming from hyprlock
  security.pam.services.hyprlock.enableGnomeKeyring = true;

  environment.systemPackages = [ pkgs.libsecret ];

  # is automatically set
  # environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";
}
