{ pkgs
, alsa-utils
, xbacklight
, flameshot
, modkey ? "Mod4"
, locker ? "${pkgs.xlockmore}/bin/xlock -mode blank"
, ... }:

{
  full = pkgs.replaceVars ./full.cfg {
    inherit alsa-utils locker xbacklight modkey flameshot;
  };

  kiosk = pkgs.replaceVars ./kiosk.lua {
    inherit modkey locker;
  };
}
