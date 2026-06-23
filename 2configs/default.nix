{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./secrets/user-passwords.nix
    ./editor/vim.nix
    ./binary-cache/nixos.nix
    ./minimal.nix
    ./secrets/ssh_server.nix
    ./core.nix
    ./ntfy-announce.nix
    # ./overlays/default.nix
    # ./security/hotfix.nix
  ];


  # boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;

  krebs = {
    enable = true;
  #   dns.providers.lan  = "hosts";
    build.user = config.krebs.users.makefu;
  };

  # default `clan machines update` target. `<host>.euer` resolves over the
  # euer wireguard overlay (hub at gum). Hosts reachable only over public
  # internet override this (see machines/gum/config.nix).
  clan.core.networking.targetHost =
    lib.mkDefault "root@${config.clan.core.settings.machine.name}.euer";
  environment.systemPackages = with pkgs; [
      nix-output-monitor
    ];

  system.stateVersion = lib.mkForce "23.05";
}
