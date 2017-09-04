{ pkgs, ... }:
{
  services.tcsd.enable = true;
  # see https://wiki.archlinux.org/index.php/Trusted_Platform_Module
  environment.systemPackages = with pkgs; [ opencryptoki tpm-tools ];
}
