{ pkgs, ... }:{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = pkgs.callPackage (import (builtins.fetchGit {
      url = "https://github.com/nix-community/NUR";
    })) {};
  };
}
