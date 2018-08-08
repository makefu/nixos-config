{ pkgs, ... }:
with import <stockholm/lib>;
let
  shack-announce = pkgs.callPackage (builtins.fetchTarball {
    url = "https://github.com/makefu/events-publisher/archive/15fbe5cc6ac9617a08a042870795f9e879d9952a.tar.gz";
    sha256 = "1bqp1qdnwx5q1w468zbm57hmpjz3x8if3j29qrqcia0vzks1s37a";
  }) {} ;
  home = "/var/lib/shackannounce";
  user = "shackannounce";
  creds = (toString <secrets>) + "/shack-announce.json";
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
            --lol INFO \
            --creds creds.json \
            --state announce.state \
            --clean --init
        fi
        echo "Running announce"
        announce-daemon \
           --lol INFO \
           --creds creds.json \
           --state announce.state
      '';
    };
  };
}
