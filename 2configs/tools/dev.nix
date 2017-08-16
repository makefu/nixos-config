{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs;[
    python35Packages.virtualenv
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
  ];
}
