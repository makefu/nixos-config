
{ config, ... }:

{
  nix = {
    binaryCaches = [
      "https://cache.euer.krebsco.de/"
    ];
    binaryCachePublicKeys = [
      "gum:iIXIFlCAotib+MgI3V/i3HMlFXiVYOT/jfP0y54Zuvg="
    ];
  };
}
