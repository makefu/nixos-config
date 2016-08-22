_:
let
  listenPort = 60123;
  xml-port = 5000;
in {
  makefu.rtorrent = {
    enable = true;
    web.enable = true;
    xmlrpc = "localhost:${toString xml-port}";
    logLevel = "debug";
    inherit listenPort;
  };
}
