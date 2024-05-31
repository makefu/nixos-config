{
  services.syncthing.user = "makefu";
  services.syncthing.settings.folders = {
    manga = {
      path = "/home/makefu/manga/live";
      id = "makefu-manga";
      devices = [ "omo" "gum" "makefu-ebook" "makefu-phone" "x" ];
    };
  };
}
