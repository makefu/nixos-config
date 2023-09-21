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

  outputs = { self, nixpkgs, lanzaboote, disko, nixos-hardware, nix-ld,
              sops-nix, stockholm, home-manager, nix-writers, vscode-server, ...}@inputs: let
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
    nixosConfigurations = lib.genAttrs [ "filepimp" "mrdavid" "x" "cake" "tsp" "wbob" "omo" "gum" "savarcast" ] (host: nixpkgs.lib.nixosSystem rec {
      # TODO inject the system somewhere else
      system = if host == "cake" then  "aarch64-linux" else "x86_64-linux";
      specialArgs = {
        inherit (inputs) nixos-hardware self stockholm ha-ara-menu nixpkgs;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (self: super: {
              inherit (self.writers) writeDash writeDashBin;
              stockholm.lib = stockholm.lib;
              ha-ara-menu = inputs.ha-ara-menu.packages.${system}.default;
              inventory4ce = inputs.inventory4ce.packages.${system}.default;
            })
            self.overlays.default
            stockholm.overlays.default
            inputs.nix-writers.overlays.default
          ] ;
        };
      };
      modules = [
        disko.nixosModules.disko
        nix-ld.nixosModules.nix-ld
        sops-nix.nixosModules.sops
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
        (./1systems + "/${host}/config.nix")
      ];

    });
  };

}
