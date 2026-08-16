# Host and user registry of the krebs mesh.
#
# The data comes from the kartei flake (github:krebs/kartei), a plain file
# tree of hosts, nets and key material that evaluates to
#
#   { hosts.<host>.nets.<net>.{ip4,ip6,addrs,aliases,via,tinc,wireguard}
#   , users.<user>.{mail,pubkey,pgp} }
#
# kartei is deliberately pure data: routing policy and derived convenience
# fields are the consumer's job and therefore live here.
{ config, lib, kartei, ... }:
let
  # kartei records `via` as a net *name*; consumers (wireguard endpoints)
  # want the net it points at, so tie the knot per host.
  resolveVia = host:
    let
      nets = lib.mapAttrs
        (_: net: net // {
          via = if net.via == null then null else nets.${net.via};
        })
        host.nets;
    in
    host // { inherit nets; };

  # kartei carries no via file for gum's wiregrill net, but every wiregrill
  # client needs gum's public endpoint to dial in.
  routes = {
    gum.nets.wiregrill.via = "internet";
  };

  hosts = lib.mapAttrs
    (name: host: resolveVia (lib.recursiveUpdate host (routes.${name} or { })))
    kartei.hosts;

  # A user's ssh.pub may hold one key per device, while
  # openssh.authorizedKeys.keys demands a single key per list entry.
  users = lib.mapAttrs
    (_: user: user // {
      pubkeys = lib.optionals (user.pubkey != null)
        (lib.filter (line: line != "") (lib.splitString "\n" user.pubkey));
    })
    kartei.users;
in
{
  options.krebs = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      description = "All hosts known to the mesh, keyed by hostname.";
    };
    users = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      description = "All users known to the mesh, keyed by username.";
    };
    self = lib.mkOption {
      type = lib.types.anything;
      default = hosts.${config.clan.core.settings.machine.name} or null;
      defaultText = "the krebs.hosts entry named like this machine";
      description = ''
        This machine's own entry in krebs.hosts, for configs that need their
        own mesh addresses. null for machines kartei does not know (liveiso).
      '';
    };
  };

  config.krebs = { inherit hosts users; };
}
