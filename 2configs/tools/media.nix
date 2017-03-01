{ pkgs, ... }:

{
  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
  };

  krebs.per-user.makefu.packages = with pkgs; [
    kodi
    streamripper
  ];
}
