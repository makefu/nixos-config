{
  pkgs,
  config,
  inputs,
  ...
}:
let
  mainUser = "makefu";
  pkg = inputs.noctalia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home-manager.users.${mainUser} = {
    imports = [ inputs.noctalia-shell.homeModules.default ];

    programs.noctalia = {
      enable = true;
      package = pkg;
      settings = {
        plugins = {
          # Local plugin dir (xdg.dataDir)/noctalia/plugins, installed by
          # 2configs/gui/wayland-common/noctalia/nostr-chat.nix.
          enabled = [ "makefu/nostr-chat" ];
        };
        plugin_settings = {
          "makefu/nostr-chat" = {
            # Absolute path: the shell's runStream/runAsync spawn it via
            # sh -c with whatever PATH the unit has.
            daemon_bin = "/run/current-system/sw/bin/nostr-chatd";
            max_history = 200;
          };
        };
      };
    };

    # Manual unit (instead of programs.noctalia.systemd.enable): keeps the
    # ExecStart pinning explicit and lets nostr-chat.nix extend PATH.
    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia - A lightweight Wayland shell and bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkg}/bin/noctalia";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
