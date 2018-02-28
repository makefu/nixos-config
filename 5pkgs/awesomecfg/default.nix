{ pkgs
, lib
, alsaUtils
, xlockmore
, xbacklight
, modkey?"Mod4"
, ... }:

{
  # replace: @alsaUtils@ @xlockmore@ @xbacklight@ @modkey@
  full = lib.makeOverridable pkgs.substituteAll {
    name = "awesome_full_config";
    inherit alsaUtils xlockmore xbacklight modkey;
    isExecutable = false;
    src = ./full.cfg;
  };

  kiosk = lib.makeOverridable pkgs.substituteAll {
    name = "awesome_kiosk_config";
    inherit alsaUtils xlockmore xbacklight modkey;
    isExecutable = false;
    src = ./kiosk.lua;
  };
}
