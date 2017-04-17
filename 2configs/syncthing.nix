{...}:

with import <stockholm/lib>; {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    useInotify = true;
    group = "download";
  };
  users.extraGroups.download.gid = genid "download";
}
