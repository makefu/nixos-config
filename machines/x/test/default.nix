{ pkgs, ... }:
let
  py = pkgs.python3.withPackages(ps: with ps; [ requests docopt pyyaml ]);
  pkg-bin = "${py.interpreter} ${./download-ticker.py}";

in
{
  systemd.services.ticker-service = {
    #wantedBy = [ "multi-user.target"];
    startAt = "hourly";
    serviceConfig = {

      DynamicUser = true;
      StateDirectory = "ticker-service";
      ExecStart = "${pkg-bin} /var/lib/ticker-service";
    };
  };
}

