{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      # Don't do this if your machines are on nixpkgs stable.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clan-core-unstable = {
      url = "git+https://git.clan.lol/clan/clan-core";
      # Don't do this if your machines are on nixpkgs stable.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };


    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    stockholm.url = "git+https://cgit.euer.krebsco.de/stockholm";
    #stockholm.url = "path:///home/makefu/stockholm-flakes";
    stockholm.inputs.nixpkgs.follows = "nixpkgs";
    stockholm.inputs.nix-writers.follows = "nix-writers";

    nix-writers.url = "git+https://cgit.krebsco.de/nix-writers";
    nix-writers.inputs.nixpkgs.follows = "nixpkgs";

    # bam inputs
    ha-ara-menu.url = "github:kalauerclub/ha_ara_menu";
    ha-ara-menu.inputs.nixpkgs.follows = "nixpkgs";

    inventory4ce.url = "github:kalauerclub/inventory4ce";
    inventory4ce.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  };
  description = "Flake of makefu";

  outputs = { self, nixpkgs, lanzaboote, disko, nixos-hardware, nix-ld, clan-core,nixpkgs-unstable,
              stockholm, home-manager, nix-writers, vscode-server, ...}@inputs: 
  let
    inherit (nixpkgs) lib;
    clan = clan-core.lib.buildClan {
      directory = self;
      specialArgs = {
        inherit (inputs) nixos-hardware self stockholm nixpkgs;
      };
      machines = lib.genAttrs [ "filepimp" "mrdavid" "x" "cake" "tsp" "wbob" "omo" "gum" "savarcast" ] (host: rec {
        # TODO inject the system somewhere else
        nixpkgs.hostPlatform = if host == "cake" then  "aarch64-linux" else "x86_64-linux";
        imports = [
          disko.nixosModules.disko
          nix-ld.nixosModules.nix-ld
          home-manager.nixosModules.default
          lanzaboote.nixosModules.lanzaboote

          stockholm.nixosModules.brockman

          stockholm.nixosModules.exim-retiolum
          stockholm.nixosModules.exim

          stockholm.nixosModules.krebs
          stockholm.nixosModules.hosts
          stockholm.nixosModules.users
          stockholm.nixosModules.build
          stockholm.nixosModules.dns
          stockholm.nixosModules.kartei
          stockholm.nixosModules.sitemap
          stockholm.nixosModules.fetchWallpaper
          stockholm.nixosModules.git
          stockholm.nixosModules.tinc
          stockholm.nixosModules.systemd
          stockholm.nixosModules.setuid
          stockholm.nixosModules.urlwatch

          self.nixosModules.default
          vscode-server.nixosModules.default
          #self.nixosModules.krebs
          (./machines + "/${host}/config.nix")
        ];

      });
    };
  in {
    inherit (clan) nixosConfigurations clanInternals;
    nixosModules =
    builtins.listToAttrs
      (map
        (name: {name = lib.removeSuffix ".nix" name; value = import (./3modules + "/${name}");})
        (lib.filter
          (name: !lib.hasPrefix "." name)
          (lib.attrNames (builtins.readDir ./3modules))));

    overlays.default = import ./5pkgs/default.nix;
    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.mkShell {
          packages = [
            inputs.clan-core-unstable.packages.x86_64-linux.clan-cli
            pkgs.age
          ];
    };
  };

}
