# Certificate relay: solve DNS-01 for *.${domain} on the hub (gum) and push
# the issued cert over the euer tunnel to wireguard-only hosts, where nginx
# terminates TLS with the real LE cert. Keyed per domain instance
# (makefu.cert-relay.<n>); server runs on the hub, client on each target.
#
# The per-instance iteration must only ever appear in option *values* under
# statically-named keys (systemd.services, security.acme.certs, ...). This
# nixpkgs' module system forces every module config's key structure while
# type-checking the attrset-of-submodule option itself, so a top-level
# `mkMerge (mapAttrsToList ...)` over config.makefu.cert-relay recurses.
let
  optionsModule = { lib, ... }: {
    options.makefu.cert-relay = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, ... }: {
            options = {
              domain = lib.mkOption {
                type = lib.types.str;
                description = "Parent domain; the cert covers *.domain";
              };
              certName = lib.mkOption {
                type = lib.types.str;
                description = "security.acme.certs key; must not contain '*'";
              };
              pubKey = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Authorized-keys line of the relay push keypair";
              };
              dnsProvider = lib.mkOption {
                type = lib.types.str;
                default = "netcupv1"; # new netcup CloudDNS API; "netcup" = legacy
              };
              server = {
                enable = lib.mkEnableOption "cert-relay push side (ACME + rsync)";
                targets = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                  description = "Hostnames to push the cert to (euer-resolvable)";
                };
              };
              client = {
                enable = lib.mkEnableOption "cert-relay receive side";
                reloadUnits = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ "nginx.service" ];
                };
              };
            };
            config = {
              # Default the acme cert key to the domain with dots dash-substituted.
              certName = lib.mkDefault (builtins.replaceStrings [ "." ] [ "-" ] config.domain);
            };
          }
        )
      );
      default = { };
    };
  };

  implModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      all = config.makefu.cert-relay;

      # ---- push side (gum) ----
      pushEnabled = n: cfg: cfg.server.enable;
      certDefs = lib.mapAttrs' (
        n: cfg:
        lib.nameValuePair cfg.certName (
          lib.mkIf (pushEnabled n cfg) {
            domain = "*.${cfg.domain}";
            dnsProvider = cfg.dnsProvider;
            environmentFile = config.sops.secrets."lego-syntax-fehler".path;
            renewInterval = "daily";
            # postRun only fires when the renew unit wrote the `renewed`
            # marker, i.e. on actual issuance/renewal -> push immediately.
            postRun = "${pkgs.systemd}/bin/systemctl start cert-push-${n}.service";
          }
        )
      );

      pushServiceDefs = lib.mapAttrs' (
        n: cfg:
        lib.nameValuePair "cert-push-${n}" (
          lib.mkIf (pushEnabled n cfg) {
            description = "Push ${cfg.domain} wildcard cert to relay targets";
            after = [
              "network-online.target"
              "wireguard-euer.service"
              "acme-${cfg.certName}.service"
            ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
            };
            path = [
              pkgs.rsync
              pkgs.openssh
            ];
            script = ''
              key=${config.sops.secrets."gum-cert-relay.key".path}
              src=/var/lib/acme/${cfg.certName}/
              for host in ${lib.escapeShellArgs cfg.server.targets}; do
                ${pkgs.rsync}/bin/rsync -rltO --no-perms --no-o --no-g \
                  --chmod=D2770,F0640 \
                  -e "${pkgs.openssh}/bin/ssh -i $key -o IdentitiesOnly=yes \
                        -o StrictHostKeyChecking=accept-new \
                        -o UserKnownHostsFile=/var/lib/cert-relay/known_hosts" \
                  "$src" "cert-receiver@$host:/var/lib/cert-relay/${cfg.domain}/"
              done
            '';
          }
        )
      );

      pushTimerDefs = lib.mapAttrs' (
        n: cfg:
        # Backstop: a target that was offline at renewal time catches up
        # within a day without re-issuing.
        lib.nameValuePair "cert-push-${n}" (
          lib.mkIf (pushEnabled n cfg) {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "daily";
              Persistent = "yes";
              RandomizedDelaySec = 3600;
            };
          }
        )
      );

      pushTmpfiles =
        n: cfg:
        lib.optionals (pushEnabled n cfg) [
          # known_hosts dir for accept-new on first push
          "d /var/lib/cert-relay 0700 root root -"
        ];

      # ---- receive side (each target host) ----
      receiveEnabled = cfg: cfg.client.enable;

      receiveTmpfiles =
        n: cfg:
        lib.optionals (receiveEnabled cfg) [
          "d /var/lib/cert-relay 0755 root root -"
          "d /var/lib/cert-relay/${cfg.domain} 2770 root nginx -"
        ];

      certPathDefs = lib.mapAttrs' (
        n: cfg:
        # PathChanged on the directory fires on rsync's rename-into-place.
        lib.nameValuePair "cert-${n}" (
          lib.mkIf (receiveEnabled cfg) {
            wantedBy = [ "multi-user.target" ];
            pathConfig = {
              PathChanged = "/var/lib/cert-relay/${cfg.domain}";
              Unit = "cert-reload-${n}.service";
            };
          }
        )
      );

      certReloadDefs = lib.mapAttrs' (
        n: cfg:
        lib.nameValuePair "cert-reload-${n}" (
          lib.mkIf (receiveEnabled cfg) {
            serviceConfig = {
              Type = "oneshot";
            };
            script = "${config.systemd.package}/bin/systemctl try-reload-or-restart ${lib.escapeShellArgs cfg.client.reloadUnits}";
          }
        )
      );
    in
    {
      config = {
        # sops decls merge by name across instances; netcup creds are shared
        # by all relay domains, push key likewise. Declared once per host that
        # runs either side; harmless (and cheap) otherwise since the files are
        # only decrypted on demand.
        sops.secrets = lib.mkIf (lib.any (c: c.server.enable) (lib.attrValues all)) {
          "lego-syntax-fehler" = { };
          "gum-cert-relay.key" = { };
        };

        security.acme.certs = certDefs all;
        systemd.services = lib.mkMerge [
          (pushServiceDefs all)
          (certReloadDefs all)
        ];
        systemd.timers = pushTimerDefs all;
        systemd.paths = certPathDefs all;
        systemd.tmpfiles.rules =
          (lib.concatLists (lib.mapAttrsToList pushTmpfiles all))
          ++ (lib.concatLists (lib.mapAttrsToList receiveTmpfiles all));

        users.groups = lib.mkIf (lib.any receiveEnabled (lib.attrValues all)) {
          cert-receiver = { };
        };
        users.users = lib.mkIf (lib.any receiveEnabled (lib.attrValues all)) {
          cert-receiver = {
            isSystemUser = true;
            group = "cert-receiver";
            # nginx master runs as the nginx user; membership + the 2770
            # group dir make the rsynced 0640 key readable by nginx only.
            extraGroups = [ "nginx" ];
            # isSystemUser defaults to nologin, which kills rsync's remote
            # server ("This account is currently not available"). The key is
            # restrict+from-pinned, so a real shell is safe here.
            shell = pkgs.bash;
            # Only gum's euer endpoints may push, and only via rsync.
            openssh.authorizedKeys.keys = lib.mapAttrsToList (
              n: cfg:
              lib.mkIf (receiveEnabled cfg) ''from="fd42:e1e0::1,172.27.70.1",restrict,no-agent-forwarding,no-X11-forwarding,no-pty ${cfg.pubKey}''
            ) all;
          };
        };

        # hosts with the receive side terminate relayed TLS
        networking.firewall.allowedTCPPorts = lib.optionals (lib.any receiveEnabled (lib.attrValues all)) [
          443
        ];
      };
    };

in
{
  imports = [
    optionsModule
    implModule
  ];
}
