{ self,pkgs, ... }:
{
  nixpkgs.overlays = [
    self.overlays.default
    (import (self.inputs.stockholm.inputs.nix-writers + "/pkgs"))
    (self: super: {
      inherit (self.writers) writeDash writeDashBin;
      stockholm.lib = self.inputs.stockholm.lib;
      ha-ara-menu = self.inputs.ha-ara-menu.packages.${pkgs.system}.default;
      inventory4ce = self.inputs.inventory4ce.packages.${pkgs.system}.default;
    })
    self.inputs.stockholm.overlays.default
  ];
}
