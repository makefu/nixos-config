{ config, pkgs, ... }:

{
  imports =
    [ ./mediawiki.nix
      ./network.nix
    ];

}
