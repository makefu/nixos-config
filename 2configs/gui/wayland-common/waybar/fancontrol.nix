{ pkgs, config, ... }:
let
  mainUser = config.krebs.build.user.name;
  fanFile = "/proc/acpi/ibm/fan";
  fanRead = pkgs.writeShellScript "waybar-fan-read" ''
    if [ ! -r "${fanFile}" ]; then
      echo '{"text":"N/A","tooltip":"Fan interface not available","class":"unavailable"}'
      exit 0
    fi
    speed=$(${pkgs.gawk}/bin/awk '/^speed:/ {print $2}' "${fanFile}")
    level=$(${pkgs.gawk}/bin/awk '/^level:/ {print $2}' "${fanFile}")
    # percentage: map 0-7 to 0-100, auto/disengaged/full-speed to 100
    case "$level" in
      [0-7]) pct=$(( level * 100 / 7 )) ;;
      *)     pct=100 ;;
    esac
    printf '{"text":"%s  %s RPM","tooltip":"Level: %s\\nSpeed: %s RPM","class":"level-%s","percentage":%d}\n' \
    "$level" "$speed" "$level" "$speed" "$level" "$pct"
  '';
  # validated helper that runs as root via sudo — only accepts known fan levels
  fanSet = pkgs.writeShellScript "thinkpad-fan-set" ''
    case "$1" in
      0|1|2|3|4|5|6|7|auto|disengaged|full-speed) ;;
      *) echo "invalid fan level: $1" >&2; exit 1 ;;
    esac
    echo "level $1" > "${fanFile}"
  '';
  fanCycle = pkgs.writeShellScript "waybar-fan-cycle" ''
    level=$(${pkgs.gawk}/bin/awk '/^level:/ {print $2}' "${fanFile}")
    case "$level" in
      auto)  next=0 ;;
      [0-6]) next=$((level + 1)) ;;
      7)     next=full-speed ;;
      *)     next=auto ;;
    esac
    sudo ${fanSet} "$next"
  '';
in {
  security.sudo.extraRules = [{
    users = [ mainUser ];
    commands = [{
      command = toString fanSet;
      options = [ "NOPASSWD" ];
    }];
  }];
  home-manager.users.${mainUser} = {
    programs.waybar.settings.mainBar = {
      "custom/fan" = {
        format = "{}";
        return-type = "json";
        interval = 3;
        exec = toString fanRead;
        exec-if = "test -r ${fanFile}";
        on-click = toString fanCycle;
        on-click-right = "sudo ${fanSet} auto";
      };
    };
  };
}
