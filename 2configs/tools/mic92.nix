{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (import <mic92/nixos/overlays/mypackages>)
  ];
  users.users.makefu.packages = [
    pkgs.nix-review
  ];
}
