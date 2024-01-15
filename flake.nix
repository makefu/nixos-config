{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      # Don't do this if your machines are on nixpkgs stable.
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    #home-manager.url = "github:nix-community/home-manager/release-23.11";
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

  outputs = { self, nixpkgs, lanzaboote, disko, nixos-hardware, nix-ld, clan-core,
               home-manager, nix-writers, vscode-server, ...}@inputs: 
  let
    inherit (nixpkgs) lib pkgs;
    pkgsForSystem = system: (import nixpkgs {
      inherit system;
      #system = "x86_64-linux";
      config.allowUnfree = true;
      config.packageOverrides = lib.mkForce (pkgs: { tinc = pkgs.tinc_pre; });
      config.allowUnfreePredicate = pkg: lib.packageName pkg == "unrar";
      overlays = [
        self.overlays.default
        inputs.nix-writers.overlays.default
        (import (inputs.stockholm.inputs.nix-writers + "/pkgs"))
        (this: super: {
          inherit (this.writers) writeDash writeDashBin;
          stockholm.lib = inputs.stockholm.lib;
          ha-ara-menu = inputs.ha-ara-menu.packages.${system}.default;
          inventory4ce = inputs.inventory4ce.packages.${system}.default;
        })
        inputs.stockholm.overlays.default
      ];
    });
    #pkgsForSystem = system: nixpkgs.legacyPackages.${system};
    clan = clan-core.lib.buildClan {
      clanName = "makefu";
      directory = self;
      specialArgs = {
        inherit (inputs) nixos-hardware self stockholm nixpkgs;
        inherit inputs;
      };
      machines = lib.genAttrs [ "filepimp" "mrdavid" "x" "cake" "tsp" "wbob" "omo" "gum" "savarcast" ] (host: rec {
        # TODO inject the system somewhere else
        #nixpkgs.hostPlatform = if host == "cake" then  "aarch64-linux" else "x86_64-linux";
        nixpkgs.pkgs = if host == "cake" then pkgsForSystem "aarch64-linux" else pkgsForSystem "x86_64-linux";
        imports = [
          disko.nixosModules.disko
          nix-ld.nixosModules.nix-ld
          home-manager.nixosModules.default
          lanzaboote.nixosModules.lanzaboote

          inputs.stockholm.nixosModules.brockman
          inputs.stockholm.nixosModules.exim-retiolum
          inputs.stockholm.nixosModules.exim
          inputs.stockholm.nixosModules.krebs
          inputs.stockholm.nixosModules.hosts
          inputs.stockholm.nixosModules.users
          inputs.stockholm.nixosModules.build
          inputs.stockholm.nixosModules.dns
          inputs.stockholm.nixosModules.kartei
          inputs.stockholm.nixosModules.sitemap
          inputs.stockholm.nixosModules.git
          inputs.stockholm.nixosModules.tinc
          inputs.stockholm.nixosModules.systemd
          inputs.stockholm.nixosModules.setuid
          inputs.stockholm.nixosModules.urlwatch

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
            inputs.clan-core.packages.x86_64-linux.clan-cli
            pkgs.age
          ];
    };
  };

}
