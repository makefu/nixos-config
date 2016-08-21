{config, lib, pkgs, ... }:

{
  options.makefu.full-populate = lib.mkEnableOption "always do a full clone of nixpkgs";
}
