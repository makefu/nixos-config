{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs;[
    python3
    python3Packages.pyserial
    python3Packages.virtualenv
    # embedded
    gi
    flashrom
    mosquitto
    libcoap
    nodemcu-uploader
    esptool
    cac-api
    cac-panel
    krebszones
    ovh-zone
    whatsupnix
    brain
    gen-oath-safe
    cdrtools
    # nix related
    nix-repl
    nix-index
    # git-related
    tig
  ];
}
