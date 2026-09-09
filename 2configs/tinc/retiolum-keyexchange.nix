{ lib, config, ... }:
{
  systemd.services."tincr-retiolum".serviceConfig.ExecStart = lib.mkForce (
    lib.concatStringsSep " " [
      "${config.services.tincr.networks.retiolum.package}/bin/tincd"
      "-D"
      "-n retiolum"
      "--pidfile=/run/tincr/retiolum.pid"
      "-o SPTPSKex=x25519"
      "-o SPTPSCipher=chacha20-poly1305"
    ]
  );
}
