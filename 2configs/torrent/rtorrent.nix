{ config, lib, pkgs, ... }:

let
  peer-port = 51412;
  daemon-port = 58846;
  dldir = config.makefu.dl-dir;
in {
  imports = [
    ./flood.nix
  ];
  services.rtorrent = {
    enable = true;
    #user = "download";
    port = peer-port;
    # package = pkgs.jesec-rtorrent;
    openFirewall = true;
    group = "download";
    dataPermissions = "0775";
    downloadDir = dldir;
    configText = ''
      schedule2 = watch_start, 10, 10, ((load.start, (cat, (cfg.watch), "/media/cloud/watch/*.torrent")))
      pieces.memory.max.set = 1800M
      network.xmlrpc.size_limit.set = 16M
      method.redirect=load.throw,load.normal
      method.redirect=load.start_throw,load.start
      method.insert=d.down.sequential,value|const,0
      method.insert=d.down.sequential.set,value|const,0
    '';
  };
  # allow access to the socket

}
