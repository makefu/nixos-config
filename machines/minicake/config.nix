{ config,nixpkgsPath, pkgs, lib, ... }:
{
  krebs = {
    enable = true;

    dns.providers.lan  = "hosts";
    build.user = config.krebs.users.makefu;
  };
  imports = [
    (nixpkgsPath + "/nixos/modules/profiles/minimal.nix")
    (nixpkgsPath + "/nixos/modules/profiles/installation-device.nix")
  ];

  # cifs-utils fails to cross-compile
  # Let's simplify this by removing all unneeded filesystems from the image.
  boot.supportedFilesystems = lib.mkForce [ "vfat" ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;


  users.users = {
    root = {
        openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
      };
  };
  services.openssh.enable = true;
}
