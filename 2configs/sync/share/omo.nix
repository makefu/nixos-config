{
  services.syncthing.user = "download";
  services.syncthing.settings.folders = {
    the_playlist = {
      path = "/media/silent/music/the_playlist";
      devices = [ "mors" "prism" ];
    };
    manga = {
      path = "/media/silent/manga";
      id = "makefu-manga";
      devices = [ "gum" "makefu-ebook" ];
    };
  };
}
