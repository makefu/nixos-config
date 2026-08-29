{ pkgs, lib, ... }:
let
    mainUser = "makefu";
    inherit (lib.generators) mkLuaInline;
in {
  imports = [ ../wayland-common/passwords.nix ];

  home-manager.users.${mainUser} = {
    # start gnome-keyring-daemon with SSH component and propagate SSH_AUTH_SOCK
    wayland.windowManager.hyprland.settings = {
      # the lua config has no exec-once: a top level hl.exec_cmd would re-run
      # on every config reload, the start event fires once per session.
      on = [
        {
          _args = [
            "hyprland.start"
            (mkLuaInline ''
              function()
                hl.exec_cmd("${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")
                hl.exec_cmd("${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets")
              end
            '')
          ];
        }
      ];

      env = [
          # Do NOT set SSH_AUTH_SOCK manually — gcr-ssh-agent sets it via systemd/xdg
          # hl.env passes the value to setenv(3) verbatim, so $VARS have to be
          # expanded in lua rather than written into the string.
          {
            _args = [
              "SSH_AUTH_SOCK"
              (mkLuaInline ''os.getenv("XDG_RUNTIME_DIR") .. "/gcr/ssh"'')
            ];
          }
      ];
    };
  };

  # unlock gnome-keyring when resuming from hyprlock
  security.pam.services.hyprlock.enableGnomeKeyring = true;
}
