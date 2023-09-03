{ pkgs, config, ... }:

{
  networking.firewall.allowedUDPPorts = [ 53 ];
  sops.secrets."iodinepw" = {
    owner = "iodined";
  };

  services.iodine = {
    server = {
      enable = true;
      domain = "io.krebsco.de";
      ip = "172.16.10.1/24";
      passwordFile = config.sops.secrets."iodinepw".path;
      extraConfig = "-c -l ${config.krebs.build.host.nets.internet.ip4.addr}";
    };
  };

}
