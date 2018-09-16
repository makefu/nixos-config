_:
# TODO: do not check out nixpkgs master but fetch revision from github
{
  environment.noXlibs = true;
  nix.gc.automatic = true;
  nix.gc.dates = "03:10";
  programs.info.enable = false;
  programs.man.enable = false;
  services.journald.extraConfig = "SystemMaxUse=50M";
  services.nixosManual.enable = false;
}
