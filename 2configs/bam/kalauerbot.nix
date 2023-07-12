{ config, lib, pkgs, ... }:
let
  oofdir = fetchTarball {
    url = "https://o.euer.krebsco.de/s/AZn9QPLGFZeDfNq/download";
    sha256 = "1wa59rkgffql6hbiw9vv0zh35wx9x1cp4bnwicprbd0kdxj75miz"; 
  };

in
{
  systemd.services.kalauerbot  = {
    description = "Kalauerbot";
    after = [ "network-online.target"  ];
    wantedBy = [ "multi-user.target"  ];
    environment = import <secrets/bureautomation/citadel.nix> // {
      "KALAUER_OOFDIR" = oofdir;
    };
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "kalauerbot";
      WorkingDirectory = "/var/lib/kalauerbot";
      ExecStart = "${pkgs.kalauerbot}/bin/kalauerbot";
      PrivateTmp = true;

      Restart = "always";
      RuntimeMaxSec = "12h";
    };
  };
}
