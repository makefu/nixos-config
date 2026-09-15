# Secure Boot via lanzaboote (mirrors machines/x2/x230/secureboot.nix).
#
# Do NOT hard-code per-host disk settings here; machine-specific measured
# boot / auto-cryptenroll knobs belong to the host's rootdisk module.
{ lib, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    # Must live outside the Nix store so private keys are not world-readable.
    pkiBundle = "/var/lib/sbctl";

    autoGenerateKeys.enable = true;

    # MS KEK enrollment is intentionally disabled. fwupd dbx updates and
    # signed option ROMs (GPUs, NICs) may stop working after enrollment;
    # enable includeMicrosoftKeys if your hardware needs them.
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
