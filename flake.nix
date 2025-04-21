{
  inputs = {
    #nixpkgs_stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    brockman = {
      url = "github:kmein/brockman";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";

    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      # Don't do this if your machines are on nixpkgs stable.
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    #home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    stockholm.url = "git+https://cgit.euer.krebsco.de/makefu/stockholm.git";
    #stockholm.url = "path:///home/makefu/r/stockholm";
    stockholm.inputs.nixpkgs.follows = "nixpkgs";
    stockholm.inputs.nix-writers.follows = "nix-writers";

    brother_ql_web.url = "github:makefu/brother_ql_web";
    #brother_ql_web.inputs.nixpkgs.follows = "nixpkgs";

    nix-writers.url = "git+https://cgit.krebsco.de/nix-writers";
    nix-writers.inputs.nixpkgs.follows = "nixpkgs";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # bam inputs
    ha-ara-menu.url = "github:kalauerclub/ha_ara_menu";
    ha-ara-menu.inputs.nixpkgs.follows = "nixpkgs";
    ha-ara-menu.inputs.poetry2nix.follows = "poetry2nix";

    inventory4ce.url = "github:kalauerclub/inventory4ce";
    #inventory4ce.inputs.nixpkgs.follows = "nixpkgs";
    #inventory4ce.inputs.poetry2nix.follows = "poetry2nix";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.flake-parts.follows = "flake-parts";
    #lanzaboote.inputs.pre-commit-hooks-nix.follows = "";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    audio-scripts.url = "github:makefu/audio-scripts";
    audio-scripts.inputs.nixpkgs.follows = "nixpkgs";

    nether = {
      url = "github:lassulus/nether";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.clan-core.follows = "clan-core";
    };

    buildbot-nix.url = "github:Mic92/buildbot-nix";
    buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
    buildbot-nix.inputs.flake-parts.follows = "flake-parts";
    # buildbot-nix.inputs.treefmt-nix.follows = "treefmt-nix";
  };

  description = "Flake of makefu";

  outputs = { self, nixpkgs, lanzaboote, nixos-hardware, nix-ld, clan-core,
               home-manager, nix-writers, vscode-server, ...}@inputs: 
  let
    inherit (nixpkgs) lib pkgs;
    pkgsForSystem = system: (import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        packageOverrides = lib.mkForce (pkgs: { tinc = pkgs.tinc_pre; });
        allowUnfreePredicate = pkg: lib.packageName pkg == "unrar";
        android_sdk.accept_license = true;
        oraclejdk.accept_license = true;
      };
      overlays = [
        self.overlays.default
        inputs.nix-writers.overlays.default
        (import (inputs.stockholm.inputs.nix-writers + "/pkgs"))
        (self: super: {
          inherit (self.writers) writeDash writeDashBin;
          stockholm.lib = inputs.stockholm.lib;
          ha-ara-menu = inputs.ha-ara-menu.packages.${system}.default;
          inventory4ce = inputs.inventory4ce.packages.${system}.default;
        })
        inputs.stockholm.overlays.default
      ];
    });
    #pkgsForSystem = system: nixpkgs.legacyPackages.${system};
    clan = clan-core.lib.buildClan {
      meta.name = "makefu";
      directory = self;
      specialArgs = {
        inherit (inputs) nixos-hardware self stockholm nixpkgs;
        inherit inputs;
      };
      machines = lib.genAttrs [ "liveiso" "filepimp" "x" "cake" "tsp" "wbob" "omo" "gum" "savarcast" ] (host: rec {
        # TODO inject the system somewhere else
        nixpkgs.hostPlatform = if host == "cake" then  "aarch64-linux" else "x86_64-linux";
        # nixpkgs.pkgs = if host == "cake" then pkgsForSystem "aarch64-linux" else pkgsForSystem "x86_64-linux";
        imports = [
          ./2configs/nixpkgs-config.nix
          clan-core.inputs.disko.nixosModules.disko
          nix-ld.nixosModules.nix-ld
          home-manager.nixosModules.default
          lanzaboote.nixosModules.lanzaboote

          #inputs.stockholm.nixosModules.brockman
          inputs.brockman.nixosModule
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

          inputs.nether.nixosModules.hosts

          self.nixosModules.default
          vscode-server.nixosModules.default
          #self.nixosModules.krebs
          (./machines + "/${host}/config.nix")

          inputs.buildbot-nix.nixosModules.buildbot-master
          inputs.buildbot-nix.nixosModules.buildbot-worker

        ];

      });
    };
  in {
    inherit (clan) nixosConfigurations clanInternals;
    checks = let
      a64 = "aarch64-linux";
      x86 = "x86_64-linux";
    in {
      "${a64}" = lib.mapAttrs' (name: config: lib.nameValuePair "nixos-${a64}-${name}" config.config.system.build.toplevel) ((lib.filterAttrs (_: config: config.pkgs.system == a64)) self.nixosConfigurations);
      "${x86}" = lib.mapAttrs' (name: config: lib.nameValuePair "nixos-${x86}-${name}" config.config.system.build.toplevel) ((lib.filterAttrs (_: config: config.pkgs.system == x86)) self.nixosConfigurations);
    };
    nixosModules =
    builtins.listToAttrs
      (map
        (name: {name = lib.removeSuffix ".nix" name; value = import (./3modules + "/${name}");})
        (lib.filter
          (name: !lib.hasPrefix "." name)
          (lib.attrNames (builtins.readDir ./3modules))));

          overlays.default = import ./5pkgs/default.nix;
    packages.x86_64-linux.liveiso = self.nixosConfigurations.liveiso.config.system.build.isoImage;
    packages.x86_64-linux.default = self.packages.x86_64-linux.liveiso;
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
