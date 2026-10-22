# nostr-chat noctalia plugin (makefu/noctalia-plugins) for the makefu session:
# a chat panel that DMs the opencrow bot over the euer strfry relay.
#
# The v5 plugin (plugin.toml + Luau) is installed into the shell's local
# plugin root ($XDG_DATA_HOME/noctalia/plugins); enablement and settings
# flow via programs.noctalia.settings in default.nix — no plugins.json
# patching anymore. The NIP-17 daemon runs as a systemd user unit from the
# flake's module; the panel's service entry talks to it through the
# daemon's own listen/cmd subcommands (no shell→socket code needed).
{
  config,
  pkgs,
  inputs,
  ...
}:
let
  mainUser = "makefu";
  pluginSrc = "${inputs.noctalia-plugins.outPath}/nostr-chat";
  # opencrow bot identity (sops secret opencrow-nostr-env on omo)
  botPubkey = "3e56f0c29325a95907cb7ead3bd7c918c1177b9fee12fdb787bd8223d2ffaacd";
in
{
  imports = [ inputs.noctalia-plugins.nixosModules.nostr-chat ];

  # 0600 makefu: the daemon's secretCommand runs in the user session.
  sops.secrets.x-nostr-nsec = {
    owner = mainUser;
    mode = "0400";
  };

  services.nostr-chat = {
    peerPubkey = botPubkey;
    relays = [ "ws://nostr.euer" ];
    # encrypted image attachments upload here (route96 on omo); the URL in the
    # kind-15 tag is public_url, so downloads go to the same host.
    blossom = [ "http://nostr-files.euer" ];
    secretCommand = "cat ${config.sops.secrets.x-nostr-nsec.path}";
    displayName = "opencrow";
    # no noctalia-shell on PATH needed anymore: events flow over the unix
    # socket, not `ipc call` children.
    extraPath = [ ];
  };

  # the daemon binary on the system PATH (/run/current-system/sw/bin) for
  # the plugin's daemon_bin setting and manual use.
  environment.systemPackages = [
    inputs.noctalia-plugins.packages.${pkgs.stdenv.hostPlatform.system}.nostr-chatd
  ];

  home-manager.users.${mainUser} = {
    # v5 local plugin root: the registry scans <dir>/<subdir>/plugin.toml.
    home.file.".local/share/noctalia/plugins/nostr-chat".source = pluginSrc;

    # attach-from-clipboard (📎 in the panel) shells out to wl-paste from
    # the shell's runAsync.
    home.packages = [ pkgs.wl-clipboard ];

    # The noctalia unit's sh -c spawns need wl-paste and nostr-chatd;
    # `path` prepends their bin dirs to the unit's default PATH instead
    # of clobbering Environment=PATH wholesale.
    systemd.user.services.noctalia.serviceConfig.path = [
      pkgs.wl-clipboard
      inputs.noctalia-plugins.packages.${pkgs.stdenv.hostPlatform.system}.nostr-chatd
    ];
  };
}
