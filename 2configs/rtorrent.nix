_:
let
  listenPort = 60123;
  xml-port = 5000;
  authfile = <torrent-secrets/authfile>;
in {
  makefu.rtorrent = {
    enable = true;
    web = {
      enable = true;
      enableAuth = true;
      inherit authfile;
    };
    rutorrent.enable = true;
    enableXMLRPC = true;
    logLevel = "debug";
    inherit listenPort;
  };
}
