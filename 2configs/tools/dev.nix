{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs;[
    (python3.withPackages(ps: [
      ps.python-language-server
      # the following plugins are optional, they provide type checking, import sorting and code formatting
      ps.pyls-mypy ps.pyls-isort ps.pyls-black
      ps.virtualenv
    ]))
    picocom
    python3.pkgs.pyserial
    python3.pkgs.virtualenv
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
    nix-index
    nix-review
    # git-related
    tig
    (pkgs.callPackage ./init-host {})
  ];
}
