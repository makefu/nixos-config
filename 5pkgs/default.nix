{ pkgs, ... }:

let
  inherit (pkgs) callPackage;
in
{
  alsa-hdspmixer = callPackage ./alsa-tools { alsaToolTarget="hdspmixer";};
  alsa-hdspconf = callPackage ./alsa-tools { alsaToolTarget="hdspconf";};
  alsa-hdsploader = callPackage ./alsa-tools { alsaToolTarget="hdsploader";};
  tinc_graphs = callPackage ./tinc_graphs {};
}
