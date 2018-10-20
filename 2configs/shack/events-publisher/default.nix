{ pkgs, ... }:
with import <stockholm/lib>;
let
  shack-announce = pkgs.callPackage (builtins.fetchTarball {
    url = "https://github.com/makefu/events-publisher/archive/670f4d7182a41b6763296e301612499d2986f213.tar.gz";
    sha256 = "1yf9cb08v4rc6x992yx5lcyn62sm3p8i2b48rsmr4m66xdi4bpnd";
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
