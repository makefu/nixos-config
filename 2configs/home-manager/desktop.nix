{ pkgs, lib, config, ... }:

{

  users.users.makefu.packages = with pkgs;[ bat direnv ];
  home-manager.users.makefu = {
    #programs.beets.enable = true;
    programs.firefox = {
      enable = true;
    };
    programs.obs-studio.enable = true;
    xdg.enable = true;

    programs.chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
        # "liloimnbhkghhdhlamdjipkmadhpcjmn" # krebsgold
        "fpnmgdkabkmnadcjpehmlllkndpkmiak" # wayback machine
        "gcknhkkoolaabfmlnjonogaaifnjlfnp" # foxyproxy
        "abkfbakhjpmblaafnpgjppbmioombali" # memex
        "kjacjjdnoddnpbbcjilcajfhhbdhkpgk" # forest
      ];
    };
  };
}
