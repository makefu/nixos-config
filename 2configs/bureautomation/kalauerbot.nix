{ config, lib, pkgs, ... }:

{
  systemd.services.kalauerbot  = {
    description = "Kalauerbot";
    after = [ "network-online.target"  ];
    wantedBy = [ "multi-user.target"  ];
    environment = import <secrets/bureautomation/citadel.nix>;
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "kalauerbot";
      WorkingDirectory = "/var/lib/kalauerbot";
      ExecStart = "${pkgs.kalauerbot}/bin/kalauerbot";
      PrivateTmp = true;
    };
  };
}
