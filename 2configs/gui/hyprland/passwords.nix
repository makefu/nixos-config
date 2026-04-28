{ pkgs, config, ... }:
let
    mainUser = config.krebs.build.user.name;
in {
  imports = [ ../wayland-common/passwords.nix ];

  home-manager.users.${mainUser} = {
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

  # unlock gnome-keyring when resuming from hyprlock
  security.pam.services.hyprlock.enableGnomeKeyring = true;
}
