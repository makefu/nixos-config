{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs;[
    python35Packages.virtualenv
    # embedded
    flashrom
    mosquitto
    libcoap
    nodemcu-uploader
    esptool
    cac-api
    cac-panel
    krebszones
  ];
}
