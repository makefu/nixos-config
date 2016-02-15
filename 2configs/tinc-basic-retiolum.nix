{ config, lib, pkgs, ... }:

with config.krebs.lib;
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
