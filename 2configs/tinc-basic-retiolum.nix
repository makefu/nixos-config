{ config, lib, pkgs, ... }:

with lib;
{
  krebs.retiolum = {
    enable = true;
    connectTo = [
      "gum"
      "pigstarter"
      "fastpoke"
      "ire"
    ];
  };
}
