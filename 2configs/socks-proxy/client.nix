# On-demand socks5 proxy: firefox/foxyproxy points at 127.0.0.1:23456, the
# socket activates an `ssh -D` tunnel to gum, and both go away again once the
# socket has been idle (see ./common.nix for the timeout).
#
# `ssh -D` cannot inherit a listening socket from systemd, so the socket unit
# feeds systemd-socket-proxyd, which forwards to the port ssh binds locally.
{ config, pkgs, lib, ... }:
let
  cfg = import ./common.nix;
  secret = "${config.clan.core.settings.machine.name}-socks-proxy.key";

  knownHosts = pkgs.writeText "socks-proxy-known-hosts"
    "${cfg.serverHost} ${config.krebs.hosts.gum.ssh.pubkey}";

  common = {
    User = cfg.user;
    Group = cfg.user;
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectHome = true;
    ProtectSystem = "strict";
  };
in {
  users.groups.${cfg.user} = { };
  users.users.${cfg.user} = {
    isSystemUser = true;
    group = cfg.user;
  };

  sops.secrets.${secret}.owner = cfg.user;

  systemd.sockets.socks-proxy = {
    description = "socks5 proxy to ${cfg.serverHost}";
    wantedBy = [ "sockets.target" ];
    socketConfig.ListenStream = [
      "127.0.0.1:${toString cfg.socksPort}"
      "[::1]:${toString cfg.socksPort}"
    ];
  };

  systemd.services.socks-proxy = {
    description = "socks5 proxy to ${cfg.serverHost}";
    requires = [ "socks-proxy-ssh.service" ];
    after = [ "socks-proxy-ssh.service" ];
    serviceConfig = common // {
      ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd"
        + " --exit-idle-time=${cfg.idleTimeout} 127.0.0.1:${toString cfg.tunnelPort}";
    };
  };

  systemd.services.socks-proxy-ssh = {
    description = "ssh dynamic forward backing socks-proxy.service";
    # no wantedBy: pulled in by socks-proxy.service and dropped again once
    # systemd-socket-proxyd exits on idle
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = common // {
      Type = "exec";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.openssh}/bin/ssh -N"
        "-D 127.0.0.1:${toString cfg.tunnelPort}"
        "-i ${config.sops.secrets.${secret}.path}"
        "-o IdentitiesOnly=yes -o BatchMode=yes"
        "-o ExitOnForwardFailure=yes"
        "-o StrictHostKeyChecking=yes"
        "-o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=${knownHosts}"
        # notice a dead tunnel instead of hanging the browser on it
        "-o ServerAliveInterval=30"
        "${cfg.user}@${cfg.serverHost}"
      ];
      # systemd-socket-proxyd does not retry, so this start job must not finish
      # before the forward is bound. TimeoutStartSec bounds the wait.
      ExecStartPost = "${pkgs.runtimeShell} -c "
        + "'until (echo > /dev/tcp/127.0.0.1/${toString cfg.tunnelPort}) 2>/dev/null; do sleep 0.1; done'";
      TimeoutStartSec = "30s";
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };
}
