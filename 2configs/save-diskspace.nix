_:
# TODO: do not check out nixpkgs master but fetch revision from github
{
  services.nixosManual.enable = false;
  programs.man.enable = false;
  services.journald.extraConfig = "SystemMaxUse=50M";
  nix.gc.automatic = true;
  nix.gc.dates = "03:10";
}
