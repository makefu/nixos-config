{ pkgs, ... }:
with import <stockholm/lib>;
let
  shack-announce = pkgs.callPackage (builtins.fetchTarball {
    url = "https://github.com/makefu/events-publisher/archive/419afdfe16ebf7f2360d2ba64b67ca88948832bd.tar.gz";
    sha256 = "0rn1ykgjbd79zg03maa49kzi6hpzn4xzf4j93qgx5wax7h12qjx0";
  }) {} ;
  home = "/var/lib/shackannounce";
  user = "shackannounce";
  creds = (toString <secrets>) + "/shack-announce.json";
  LOL = "DEBUG";
in
{
  users.users.${user}= {
    uid = genid user;
    inherit home;
    createHome = true;
  };
  systemd.services.shack-announce = {
    description = "Announce shack events";
    startAt = "*:0/30";
    path = [ shack-announce ];
    serviceConfig  = {
      WorkingDirectory = home;
      User = user;
      PermissionsStartOnly = true;
      ExecStartPre = pkgs.writeDash "shack-announce-pre" ''
        set -eu
        cp ${creds} creds.json
        chown ${user} creds.json
      '';
      ExecStart = pkgs.writeDash "shack-announce" ''
        if test ! -e announce.state; then
          echo "initializing state"
          announce-daemon \
            --lol ${LOL} \
            --creds creds.json \
            --state announce.state \
            --clean --init
        fi
        echo "Running announce"
        announce-daemon \
           --lol ${LOL} \
           --creds creds.json \
           --state announce.state
      '';
    };
  };
}
