{ pkgs, ... }:
let
  cfg = pkgs.writeText "hcl-config.json" (builtins.toJSON {
    engine =  "rhasspy";
    pathToConfig = "/var/lib/rhasspy/de/profile.json";
    hardware =  "respeaker4MicArray";
    pattern = "fake-name";
    enableDoA = false;
  });
in {
  systemd.services.HermesLedControl = {
    description = "Led Server for ReSpeaker 4-array";
    after = [ "network-online.target"  "docker-rhasspy.service" ] ;
    wantedBy = [ "multi-user.target"  ];
    serviceConfig = {
      # User = "nobody"; # need a user with permissions to run nix-shell
      ExecStart = "${pkgs.HermesLedControl}/bin/HermesLedControl --hermesLedControlConfig=${toString cfg}";
      Restart = "always";
      RestartSec = 10;
      PrivateTmp = true;
    };
  };
}
