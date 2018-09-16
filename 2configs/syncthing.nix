{ config, ... }:

with import <stockholm/lib>; {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    group = "download";
  };
  users.extraGroups.download.gid = genid "download";
  state = map (x: config.services.syncthing.dataDir + "/" + x) [
    "key.pem"
    "cert.pem"
    "config.xml"
    "https-cert.pem"
    "https-key.pem"
  ];
}
