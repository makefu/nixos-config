{ services,builtins,environment,pkgs, ... }:

let
  # TODO: make this a parameter
  domain = "io.krebsco.de";
  pw = import <secrets/iodinepw.nix>;
in {

  services.iodined = {
    enable = true;
    domain = domain;
    ip = "172.16.10.1/24";
    extraConfig = "-P ${pw}";
  };

}
