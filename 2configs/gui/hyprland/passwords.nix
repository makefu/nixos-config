{ pkgs, config, ... }: 
let
    mainUser = config.krebs.build.user.name;
    share = "/home/makefu/.local/share";
in {
  # Terminal
  home-manager.users.${mainUser} = {
    services.ssh-agent.enable = true;
    programs.rbw = {
      enable = true;
      settings.base_url = "bw.euer.krebsco.de";
      settings.email = "makefu@x";
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
  # according to https://old.reddit.com/r/NixOS/comments/1bbjqcn/how_to_enable_gnomekeyring_in_hyprland/
  environment.systemPackages = [pkgs.libsecret];
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";
}
