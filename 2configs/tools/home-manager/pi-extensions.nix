{ pkgs, inputs, config, ... }:
let
  extSrc = inputs.pi-agent-extensions;
in
{
  # Mirrors Mic92/dotfiles: each wanted extension is entered via pi's
  # auto-discovery in ~/.pi/agent/extensions; nushell is loaded through the
  # package source instead so its sibling modules (ast.ts, gate.ts) resolve.
  # "!*" keeps the rest of the repo's extensions disabled.
  home.file.".pi/agent/extensions/statusline".source = "${extSrc}/statusline";
  home.file.".pi/agent/extensions/permission-gate".source = "${extSrc}/permission-gate";
  home.file.".pi/agent/extensions/notify.ts".source = "${extSrc}/notify/index.ts";
  home.file.".pi/agent/extensions/questionnaire.ts".source = "${extSrc}/questionnaire/index.ts";

  # Stable, store-path-free handle for the package source: ~/.pi/agent/
  # settings.json is an out-of-store symlink into the repo, so it must not
  # reference a /nix/store path that changes on every input bump. pi
  # expands `~`, hence the tilde in settings.json works.
  home.file.".local/share/pi-agent-extensions".source = extSrc;

  # Out-of-store symlink: pi and the user can edit the file in place, and
  # those edits land as diffs on the checked-in file (repo is in state).
  # force: on the first switch this replaces the existing unmanaged
  # settings.json, whose content was carried over into pi-settings.json.
  home.file.".pi/agent/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/home/makefu/nixos-config/2configs/tools/home-manager/pi-settings.json";
    force = true;
  };

  # The nushell extension parses tool input with the `nu` binary.
  home.packages = [ pkgs.nushell ];

  xdg.configFile."pi-statusline/settings.json".source =
    (pkgs.formats.json { }).generate "pi-statusline-settings.json" {
      showUsage = false;
      showBar = true;
      contextFormat = "absolute";
    };
}
