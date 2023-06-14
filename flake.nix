{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    # stockholm.url = "git+https://cgit.lassul.us/stockholm?ref=flakeify";
    stockholm.url = "path:///home/makefu/stockholm-flakes";
    stockholm.inputs.nixpkgs.follows = "nixpkgs";

  };
  description = "Flakes of makefu";

  outputs = { self, nixpkgs, disko, nixos-hardware, nix-ld, sops-nix, stockholm, home-manager, ...}@inputs: let
      inherit (nixpkgs) lib;
  in {
    nixosModules =
    builtins.listToAttrs
      (map
        (name: {name = lib.removeSuffix ".nix" name; value = import (./3modules + "/${name}");})
        (lib.filter
          (name: !lib.hasPrefix "." name)
          (lib.attrNames (builtins.readDir ./3modules))));

    overlays.default = import ./5pkgs/default.nix;
    nixosConfigurations = lib.genAttrs ["x" "tsp" ] (host: nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit (inputs) nixos-hardware self stockholm nixpkgs;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [(self: super: { inherit (self.writers) writeDash writeDashBin; stockholm.lib = stockholm.lib; }) self.overlays.default] ;
        };
      };
      modules = [
        disko.nixosModules.disko
        nix-ld.nixosModules.nix-ld
        sops-nix.nixosModules.sops
        home-manager.nixosModules.default

        stockholm.nixosModules.krebs
        stockholm.nixosModules.hosts
        stockholm.nixosModules.users
        stockholm.nixosModules.build
        stockholm.nixosModules.dns
        stockholm.nixosModules.kartei
        stockholm.nixosModules.sitemap
        stockholm.nixosModules.fetchWallpaper
        stockholm.nixosModules.git

        self.nixosModules.default
        #self.nixosModules.krebs
        (./1systems + "/${host}/config.nix")
      ];

    });
  };

}
