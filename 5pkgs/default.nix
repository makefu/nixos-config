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
    bintray-upload = callPackage ./bintray-upload {};
    mycube-flask = callPackage ./mycube-flask {};
    nodemcu-uploader = callPackage ./nodemcu-uploader {};
    tw-upload-plugin = callPackage ./tw-upload-plugin {};
    inherit (callPackage ./devpi {}) devpi-web devpi-server;
    skytraq-logger = callPackage ./skytraq-logger {};
    taskserver = callPackage ./taskserver {};
    ps3netsrv = callPackage ./ps3netsrv {};
    honeyd = callPackage ./honeyd {};
    farpd = callPackage ./farpd {};
  };
}
