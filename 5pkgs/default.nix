{ pkgs, ... }:

let
  inherit (pkgs) callPackage;
in
{
  nixpkgs.config.packageOverrides = rec {
    alsa-hdspconf = callPackage ./alsa-tools { alsaToolTarget="hdspconf";};
    alsa-hdspmixer = callPackage ./alsa-tools { alsaToolTarget="hdspmixer";};
    alsa-hdsploader = callPackage ./alsa-tools { alsaToolTarget="hdsploader";};
    awesomecfg = callPackage ./awesomecfg {};
    bintray-upload = callPackage ./bintray-upload {};
    inherit (callPackage ./devpi {}) devpi-web devpi-server;
    f3 = callPackage ./f3 {};
    farpd = callPackage ./farpd {};
    git-xlsx-textconv = callPackage ./git-xlsx-textconv {};
    mergerfs = callPackage ./mergerfs {};
    mycube-flask = callPackage ./mycube-flask {};
    nodemcu-uploader = callPackage ./nodemcu-uploader {};
    ps3netsrv = callPackage ./ps3netsrv {};
    tw-upload-plugin = callPackage ./tw-upload-plugin {};
    skytraq-logger = callPackage ./skytraq-logger {};
    taskserver = callPackage ./taskserver {};
    udpt = callPackage ./udpt {};
    wol = callPackage ./wol {};
  };
}
