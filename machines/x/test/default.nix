{ pkgs, ... }:
let
  pkg-bin = pkgs.writers.writePython3 "download-ticker" {
    libraries = with pkgs.python3.pkgs; [ pyyaml requests docopt ];
    flakeIgnore = [  ];
  } (builtins.readFile download-ticker.py);
in
{
  systemd.services.ticker-service = {
    wantedBy = [ "multi-user.target"];
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "ticker-service";
      ExecStart = "${pkg-bin} --daemon /var/lib/ticker-service";
    };
  };
}

