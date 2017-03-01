{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs;[
    nodemcu-uploader
    esptool
    python35Packages.virtualenv
    flashrom
  ];
}
