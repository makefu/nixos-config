
{ config, ... }:

{
  nix.settings = {
    substituters = [
      "https://cache.euer.krebsco.de/"
    ];
    trusted-public-keys = [
      "gum:iIXIFlCAotib+MgI3V/i3HMlFXiVYOT/jfP0y54Zuvg="
    ];
  };
}
