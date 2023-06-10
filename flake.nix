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

  outputs = { self, nixpkgs, disko, nixos-hardware, nix-ld, sops-nix, stockholm, ...}@inputs: let


  in {
    nixosModules =
    let
      inherit (nixpkgs) lib;
    in builtins.listToAttrs
      (map
        (name: {name = lib.removeSuffix ".nix" name; value = import (./3modules + "/${name}");})
        (lib.filter
          (name: name != "default.nix" && !lib.hasPrefix "." name)
          (lib.attrNames (builtins.readDir ./3modules))));

    nixosConfigurations.x = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit (inputs) nixos-hardware self stockholm;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [(self: super: { stockholm.lib = stockholm.lib; })] ;
        };
      };
      modules = [
        disko.nixosModules.disko
        nix-ld.nixosModules.nix-ld
        sops-nix.nixosModules.sops

        stockholm.nixosModules.krebs
        stockholm.nixosModules.hosts
        stockholm.nixosModules.users
        stockholm.nixosModules.build
        stockholm.nixosModules.dns
        stockholm.nixosModules.kartei
        stockholm.nixosModules.sitemap

        self.nixosModules.state
        #self.nixosModules.krebs
        ./1systems/flake-x/config.nix
      ];

    };
  };

}
