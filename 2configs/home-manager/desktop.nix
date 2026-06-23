{ pkgs, lib, config, ... }:

{

  users.users.makefu.packages = with pkgs;[ bat direnv ];
  home-manager.users.makefu = {
    #programs.beets.enable = true;
    programs.firefox = {
      enable = true;
      # keep legacy profile path; stateVersion < 26.05 still uses ~/.mozilla
      configPath = ".mozilla/firefox";
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
        # "abkfbakhjpmblaafnpgjppbmioombali" # memex
        # "kjacjjdnoddnpbbcjilcajfhhbdhkpgk" # forest
      ];
    };
  };
}
