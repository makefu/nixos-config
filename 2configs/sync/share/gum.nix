{
  services.syncthing.user = "download";
  services.syncthing.settings.folders = {
    manga = {
      path = "/media/cloud/sync/manga/";
      id = "makefu-manga";
      devices = [ "omo" "makefu-ebook" "makefu-phone" "x" ];
    };
    audiobooks = {
      path = "/media/cloud/sync/audiobooks";
      id = "makefu-audiobooks";
      devices = [ "omo" "makefu-phone" "x" ];
    };
    download = {
      path = "/media/cloud/download/";
      id = "makefu-download";
      devices = [ "omo" ];
    };
  };
}
