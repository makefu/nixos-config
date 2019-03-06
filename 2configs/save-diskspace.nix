_:
# TODO: do not check out nixpkgs master but fetch revision from github
{
  environment.noXlibs = true;
  nix.gc.automatic = true;
  nix.gc.dates = "03:10";
  documentation.info.enable = false;
  documentation.man.enable = false;
  services.journald.extraConfig = "SystemMaxUse=50M";
  services.nixosManual.enable = false;
}
