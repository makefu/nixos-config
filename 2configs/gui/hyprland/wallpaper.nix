{config, lib, pkgs, ... }:
let
    mainUser = config.krebs.build.user.name;
    stateDir = "/home/makefu/pics/wallpaper";
    url = "http://prism.r/realwallpaper-krebs.png";

#  fetchWallpaperScript = pkgs.writers.writeDash "fetchWallpaper" ''
#      set -euf
#      PATH=$PATH:${lib.makeBinPath [pkgs.curl pkgs.hyprland]}
#      mkdir -p ${stateDir}
#      cd ${stateDir}
#      (curl -s -o wallpaper.tmp -z wallpaper.tmp ${lib.escapeShellArg url} && cp wallpaper.tmp wallpaper) || :
#      feh --no-fehbg --bg-scale wallpaper
#    '';
in {
    home-manager.users.${mainUser}.services.hyprpaper= {
        enable = true;
        settings = {
			ipc = "on";
			preload = ["/home/makefu/pics/nixos/nixos-logo-gruvbox-wallpaper/png/gruvbox-dark-blue.png"];
			wallpaper = [", /home/makefu/pics/nixos/nixos-logo-gruvbox-wallpaper/png/gruvbox-dark-blue.png"];
        };
    };
}
