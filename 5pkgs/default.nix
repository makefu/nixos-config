{ pkgs, ... }:

let
  inherit (pkgs) callPackage;
in
{
  nixpkgs.config.packageOverrides = rec {
    alsa-hdspmixer = callPackage ./alsa-tools { alsaToolTarget="hdspmixer";};
    alsa-hdspconf = callPackage ./alsa-tools { alsaToolTarget="hdspconf";};
    alsa-hdsploader = callPackage ./alsa-tools { alsaToolTarget="hdsploader";};
    awesomecfg = callPackage ./awesomecfg {};
    nodemcu-uploader = callPackage ./nodemcu-uploader {};
    mycube-flask = callPackage ./mycube-flask {};
    tw-upload-plugin = callPackage ./tw-upload-plugin {};
    inherit (callPackage ./devpi {}) devpi-web devpi-server;
  };
}
