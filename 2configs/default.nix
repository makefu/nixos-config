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
    # ./overlays/default.nix
    # ./security/hotfix.nix
  ];


  # boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;

  krebs = {
    enable = true;
  #   dns.providers.lan  = "hosts";
    build.user = config.krebs.users.makefu;
  };
  environment.systemPackages = with pkgs; [
      nix-output-monitor
    ];

  system.stateVersion = lib.mkDefault "23.05";
  services.postgresql.package = pkgs.postgresql_14;
}
