{ config, lib, pkgs, inputs, buildPythonPackage, ... }:

let
  pkg = pkgs.picsender;
  # the url to send
  url = "http://localhost:18088/?action=snapshot";
in {
  sops.secrets.citadel_config = {};
  environment.systemPackages = [ pkg ]; # debugging
  systemd.services.picsender = {
    startAt = "*-*-* 11:11:00";
    description = "picsender";
    script = "${pkg}/bin/picsender --title 'Es ist Daily Zeit!' $CREDENTIALS_DIRECTORY/config ${url}"
    serviceConfig = {
      LoadCredential = [
        "config:${config.sops.secrets.citadel_config.path}"
      ];
      DynamicUser = true; 
      PrivateTmp = true;
    };
  };
}
