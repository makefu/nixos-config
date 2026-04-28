{ pkgs, config, ... }:
let
    mainUser = config.krebs.build.user.name;
    share = "/home/makefu/.local/share";
in {
  home-manager.users.${mainUser} = {
    home.packages = with pkgs;[ gcr gnome-keyring libsecret];
    programs.rbw = {
      enable = true;
      settings.base_url = "bw.euer.krebsco.de";
      settings.identity_url = "bw.euer.krebsco.de";
      settings.email = "makefu@syntax-fehler.de";
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

  environment.systemPackages = [ pkgs.libsecret ];
}
