{pkgs, ...}:
with import <stockholm/lib>;
let
  secret = (import <secrets/elchos-token.nix>);
in {
  systemd.services.elchos-irctoken2 = {
    startAt = "*:0/5";
    serviceConfig = {
      RuntimeMaxSec = "20";
    };
    script = ''
      set -euf
      now=$(date -u +%Y-%m-%dT%H:%M)
      sleep 5
      sec=$(cat /tmp/irc-secret)
      message="The current secret is $sec"
      echo "$message"
      LOGNAME=sec-announcer
      HOSTNAME=$(${pkgs.systemd}/bin/hostnamectl --transient)
      IRC_SERVER=irc.freenode.net
      IRC_PORT=6667
      IRC_NICK=$HOSTNAME-$$
      IRC_CHANNEL='#eloop'

      export IRC_CHANNEL # for privmsg_cat

      echo2() { echo "$*"; echo "$*" >&2; }

      privmsg_cat() { ${pkgs.gawk}/bin/awk '{ print "PRIVMSG "ENVIRON["IRC_CHANNEL"]" :"$0 }'; }

      tmpdir="$(mktemp -d irc-announce_XXXXXXXX)"
      cd "$tmpdir"
      mkfifo ircin
      trap "
        rm ircin
        cd '$OLDPWD'
        rmdir '$tmpdir'
        trap - EXIT INT QUIT
      " EXIT INT QUIT

      {
        echo2 "USER $LOGNAME 0 * :$LOGNAME@$HOSTNAME"
        echo2 "NICK $IRC_NICK"

        # wait for MODE message
        ${pkgs.gnused}/bin/sed -un '/^:[^ ]* MODE /q'

        echo2 "JOIN $IRC_CHANNEL"

        printf '%s' "$message" \
          | privmsg_cat

        echo2 "PART $IRC_CHANNEL"

        # wait for PART confirmation
        sed -un '/:'"$IRC_NICK"'![^ ]* PART /q'

        echo2 'QUIT :Gone to have lunch'
      } < ircin \
        | ${pkgs.netcat}/bin/netcat "$IRC_SERVER" "$IRC_PORT" |tee -a ircin
    '';
  };
  systemd.services.elchos-create-token = {
    startAt = "*:0/30";
    serviceConfig = {
      RuntimeMaxSec = "20";
    };
    script = ''
      set -euf
      now=$(date -u +%Y-%m-%dT%H:%M)
      sec=$(echo -n "${secret}$now" | md5sum | cut -d\  -f1)
      message="The secret valid for 30 minutes is $sec"
      echo -n "$sec" > /tmp/irc-secret
      echo "token for $now (UTC) is $sec"
    '';
  };
}
