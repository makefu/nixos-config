{
  services.syncthing.user = "download";
  systemd.services.syncthing = {
    environment.GOMEMLIMIT = "400MiB";
    serviceConfig = {
      MemoryHigh="750M";
      MemoryMax="1G";
    };
  };
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
    #download = {
    #  path = "/media/cloud/download/";
    #  id = "makefu-download";
    #  #config.fsWatcherEnabled = false;
    #  #config.rescanIntervalS = 300;
    #  devices = [ "omo" ];
    #};
  };
}
