{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs;[
    python3Packages.virtualenv
    python3Packages.pyserial
    # embedded
    gi
    flashrom
    mosquitto
    libcoap
    nodemcu-uploader
    esptool
    cac-api
    cac-panel
    ovh-zone
    whatsupnix
    brain
    gen-oath-safe
    cdrtools
  ];
}
