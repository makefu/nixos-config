{ config, lib, pkgs, ... }:

let
  cfg = config.makefu.distrobump;

  imp = {
    systemd.services.distrobump = {
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.curl ];
      restartIfChanged = false;
      startAt = "daily";
      serviceConfig = {
        PrivateTmp = true;
        Type = "oneshot";
        ExecStart = pkgs.writeDash "bump-distrowatch" ''
          set -euf
          UA='Mozilla/5.0 (X11; Linux x86_64; rv:63.0) Gecko/20100101 Firefox/63.0'
          curl -Lvc /tmp/cookie.jar -A "$UA" 'https://distrowatch.com/' >/dev/null
          sleep $(shuf -i 3-15 -n1).$(shuf -i 0-9 -n1)
          curl -Lvc /tmp/cookie.jar -A "$UA" -e 'https://distrowatch.com/' 'https://distrowatch.com/nixos?frphr' >/dev/null
        '';
        RandomizedDelaySec = 28800;
      };
    };
  };
in
{
    options.makefu.distrobump.enable = lib.mkEnableOption "distrobump";
    config = lib.mkIf cfg.enable imp;
}
