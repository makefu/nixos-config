{ inputs, pkgs, ... }:
let
  pkg = inputs.audio-scripts.packages.${pkgs.system}.default;
in
{
  users.users.makefu.packages = [
    pkg
  ];
  systemd.services.mausdownload = {
    startAt = "6:15:00";
    path = [ pkg ];
    script = "alldownload.sh /media/silent/music/kinder/podcasts";
    serviceConfig= {
      User = "makefu"; # TODO unprivileged user
    };
  };
}
