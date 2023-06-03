{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs;[
    (python3.withPackages(ps: [
      #ps.python-language-server
      # the following plugins are optional, they provide type checking, import sorting and code formatting
      # ps.pyls-mypy ps.pyls-isort ps.pyls-black

      ps.virtualenv ps.pyserial ps.virtualenv
    ]))
    # embedded
    picocom
    gi
    flashrom
    mosquitto
    pwqgen-ger
    # esphome # broken

    # nix related
    nix-index
    nix-review
    brain
    whatsupnix
    nixpkgs-pytools
    nixpkgs-fmt
    hydra-check
    # git-related
    git-preview
    tig
    (pkgs.callPackage ./init-host {})
    # used more than once
    imagemagick
    qrencode
    exiftool
    cac-api
    cac-panel
    krebszones
    cyberlocker-tools
    ovh-zone
    gen-oath-safe
    cdrtools
    unrar
    ffmpeg
    dnsutils

    # network related
    sshuttle
    pciutils
    navi
    platformio
  ];
  services.udev.packages = [ pkgs.platformio ];

}
