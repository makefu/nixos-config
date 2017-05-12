{ pkgs, ...}:
{
  services.avahi = {
    enable = true;
    wideArea = false;
  };
  environment.systemPackages = [ pkgs.avahi ];
}
