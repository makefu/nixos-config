{ config, lib, pkgs, inputs, ... }:
# sends the diorama into the citadel channel
let
  pkg = inputs.picsender.packages.${pkgs.system}.default;
  # the url to send
  #url = "http://localhost:18088/?action=snapshot";
  url = "http://192.168.8.182:8080/photo.jpg";
in {
  sops.secrets.citadel_config = {};
  environment.systemPackages = [ pkg ]; # debugging
  systemd.services.daily_picsender = {
    startAt = "*-*-* 11:11:00";
    description = "picsender";
    script = "${pkg}/bin/picsender --title 'Es ist Daily Zeit!' $CREDENTIALS_DIRECTORY/config '${url}'";
    serviceConfig = {
      LoadCredential = [
        "config:${config.sops.secrets.citadel_config.path}"
      ];
      DynamicUser = true; 
      PrivateTmp = true;
    };
  };
}
