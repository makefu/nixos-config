{
  services.syncthing.user = "download";
  services.syncthing.settings.folders = {
    manga = {
      path = "/media/cloud/download/manga/live/";
      id = "makefu-manga";
      devices = [ "gum" "makefu-ebook" ];
    };
  };
}
