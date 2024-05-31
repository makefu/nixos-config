{
  services.syncthing.user = "download";
  services.syncthing.settings.folders = {
    manga = {
      path = "/media/cloud/download/manga/live/";
      id = "makefu-manga";
      devices = [ "omo" "makefu-ebook" "makefu-phone" "x" ];
    };
    download = {
      path = "/media/cloud/download/";
      id = "makefu-download";
      devices = [ "omo" ];
    };
  };
}
