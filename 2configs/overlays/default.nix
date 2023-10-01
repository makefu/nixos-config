{ self, ... }:
{
  nixpkgs.overlays = [
    self.overlays.default
    self.inputs.stockholm.overlays.default
    self.inputs.nix-writers.overlays.default
    (self: super: {
      inherit (self.writers) writeDash writeDashBin;
      stockholm.lib = stockholm.lib;
      ha-ara-menu = self.inputs.ha-ara-menu.packages.${system}.default;
      inventory4ce = self.inputs.inventory4ce.packages.${system}.default;
    })
  ];
}
