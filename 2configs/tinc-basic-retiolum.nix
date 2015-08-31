{ config, lib, pkgs, ... }:

with lib;
{
  krebs.retiolum = {
    enable = true;
    hosts = ../../krebs/Zhosts;
    connectTo = [
      "gum"
      "pigstarter"
      "fastpoke"
    ];
  };
}
