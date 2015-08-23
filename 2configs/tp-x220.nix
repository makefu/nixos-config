{ config, lib, pkgs, ... }:

with lib;
{

  imports = [ ./tp-x2x0.nix ];

  boot.kernelModules = [ "kvm-intel" ];

}
