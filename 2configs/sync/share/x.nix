{
  services.syncthing.user = "makefu";
  services.syncthing.settings.folders = {
    manga = {
      path = "/home/makefu/sync/manga";
      id = "makefu-manga";
      devices = [ "omo" "gum" "makefu-ebook" "makefu-phone" "x" ];
    };
    audiobooks = {
      path = "/home/makefu/sync/audiobooks";
      id = "makefu-audiobooks";
      devices = [ "omo" "gum" "makefu-phone" "x" ];
    };
  };
}
