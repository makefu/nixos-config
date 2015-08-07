{ config, lib, pkgs, ... }:

with lib;
{
  krebs.retiolum = {
    enable = true;
    hosts = ../../Zhosts;
    connectTo = [
      "gum"
      "pigstarter"
      "fastpoke"
    ];
  };
}
