# ibm-fan noctalia plugin (makefu/noctalia-plugins) for the makefu session:
# ThinkPad fan readout + level control (Auto/Full/0-7 slider) in the bar.
#
# Same shape as nostr-chat.nix: the v5 plugin (plugin.toml + Luau) is
# installed into the shell's local plugin root; enablement and settings flow
# via programs.noctalia.settings in default.nix.
#
# Runtime privileges: scripts/thinkpad-fan.sh writes /proc/acpi/ibm/fan
# unprivileged. On x that is granted by the tmpfiles chown in
# machines/x/t14 (owner makefu). On other ThinkPads import this file *and*
# either replicate the tmpfiles rule or run the plugin's
# scripts/setup-fan-permissions.sh once (udev fan_ctl group + 0664).
{
  config,
  pkgs,
  inputs,
  ...
}:
let
  mainUser = "makefu";
  pluginSrc = "${inputs.noctalia-plugins.outPath}/ibm-fan";
in
{
  home-manager.users.${mainUser} = {
    # v5 local plugin root: the registry scans <dir>/<subdir>/plugin.toml.
    home.file.".local/share/noctalia/plugins/ibm-fan".source = pluginSrc;

    # The shell spawns scripts/thinkpad-fan.sh via sh; bash needs to be
    # reachable from the systemd user unit's PATH.
    systemd.user.services.noctalia.serviceConfig.path = [ pkgs.bash ];
  };
}
