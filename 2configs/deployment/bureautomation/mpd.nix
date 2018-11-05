{lib,pkgs, ... }:

{
  systemd.services."ympd-wbob" = {
    description = "mpd ";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.ympd}/bin/ympd --host localhost --port 6600 --webport 8866 --user nobody";
  };
}
