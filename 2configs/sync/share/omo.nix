{
  services.syncthing.user = "download";
  services.syncthing.settings.folders = {
    the_playlist = {
      path = "/media/silent/music/the_playlist";
      devices = [ "mors" "prism" ];
    };
    manga = {
      path = "/media/crypt1/sync/manga";
      id = "makefu-manga";
      devices = [ "gum" "makefu-ebook" "makefu-phone" "x" ];
    };
    audiobooks = {
      path = "/media/crypt1/sync/audiobooks";
      id = "makefu-audiobooks";
      devices = [ "omo" "gum" "makefu-phone" "x" ];
    };
    sync-photos = {
      path = "/media/cryptX/photos/photoframe";
      id = "makefu-photoframe";
      devices = [ "makefu-tablet-medion" ];
    };
    #download = {
    #  path = "/media/crypt1/download";
    #  id = "makefu-download";
    #  devices = [ "gum" ];
    #};
  };
}
