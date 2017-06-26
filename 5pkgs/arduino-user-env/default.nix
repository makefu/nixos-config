{ lib, pkgs, ... }: let

#TODO: make sure env exists prior to running
env_nix = pkgs.writeText "env.nix" ''
  { pkgs ? import <nixpkgs> {} }:

  (pkgs.buildFHSUserEnv {
    name = "arduino-user-env";
    targetPkgs = pkgs: with pkgs; [
      coreutils
    ];
    multiPkgs = pkgs: with pkgs; [
      arduino
      alsaLib
      zlib
      xorg.libXxf86vm
      curl
      openal
      openssl_1_0_2
      xorg.libXext
      xorg.libX11
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXinerama
      xorg.libXi
      mesa_glu
    ];
    runScript = "zsh";
  }).env
'';


in pkgs.writeDashBin "arduino-user-env" ''
  nix-shell ${env_nix}
''
