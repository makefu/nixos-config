
let
  port = 8631;
  image = "bbernhard/signal-cli-rest-api:latest";
  config = "/var/lib/signal-cli-config";
in {
  systemd.tmpfiles.rules = [
    "d ${config} docker docker - -"
  ];
  state = [ config ];
  virtualisation.oci-containers.containers.signal-rest = {
    image = image;
    ports = [ "127.0.0.1:${toString port}:8080" ];
    volumes = [
      "${config}:/home/.local/share/signal-cli"
    ];
    environment.MODE ="json-rpc";
    #environment.MODE ="native"; # only required for reigstration
  };
}
