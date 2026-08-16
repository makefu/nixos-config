# Server side of the on-demand socks5 tunnel (see ./client.nix).
{ pkgs, ... }:
let
  cfg = import ./common.nix;
in {
  users.groups.${cfg.user} = { };
  users.users.${cfg.user} = {
    isSystemUser = true;
    group = cfg.user;
    # the client runs `ssh -N`, which never opens a session channel, so this
    # account never needs a usable shell
    shell = "${pkgs.shadow}/bin/nologin";
    openssh.authorizedKeys.keys = [
      # `restrict` drops agent/x11/pty/exec, `port-forwarding` hands back only
      # what `ssh -D` needs. No permitopen: a socks proxy dials arbitrary hosts.
      "restrict,port-forwarding ${cfg.clientPubkey}"
    ];
  };
}
