{ config, pkgs, lib, ... }:
let
  hostName = config.networking.hostName;
  topic = "https://ntfy.euer.krebsco.de/nix";
  userPath = config.sops.secrets.ntfy-nix-user.path;
  passPath = config.sops.secrets.ntfy-nix-pass.path;
in
{
  sops.secrets.ntfy-nix-user = {};
  sops.secrets.ntfy-nix-pass = {};

  system.activationScripts.ntfyAnnounce = {
    deps = [ "setupSecrets" ];
    text = ''
      if [ -r ${userPath} ] && [ -r ${passPath} ]; then
        (
          user=$(cat ${userPath})
          pass=$(cat ${passPath})
          kernel=$(${pkgs.coreutils}/bin/uname -r)
          when=$(${pkgs.coreutils}/bin/date --iso-8601=seconds)
          msg="${hostName} activated $when kernel=$kernel"
          echo "$msg"
          ${pkgs.curl}/bin/curl -fsS --max-time 15 \
            -u "$user:$pass" \
            -H "Title: ${hostName} nixos activation" \
            -H "Tags: package,${hostName}" \
            -d "$msg" \
            ${topic} >/dev/null || true
        ) &
        disown || true
      else
        echo "unable to announce activation, ${userPath} does not exist"
      fi
    '';
  };
}
