{
  services.syncthing.user = "download";
  services.syncthing.settings.folders = {
    the_playlist = {
      path = "/media/silent/music/the_playlist";
      devices = [ "mors" "prism" ];
    };
    manga = {
      path = "/media/crypt1/download/manga/live";
      id = "makefu-manga";
      devices = [ "gum" "makefu-ebook" "makefu-phone" "x" ];
    };
    download = {
      path = "/media/crypt1/download";
      id = "makefu-download";
      devices = [ "gum" ];
    };
  };
}
