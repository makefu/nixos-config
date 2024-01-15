{lib, self, inputs, config, ... }:{
    nixpkgs = {
      config.allowUnfree = true;
      config.packageOverrides = lib.mkForce (pkgs: { tinc = pkgs.tinc_pre; });
      config.allowUnfreePredicate = pkg: lib.packageName pkg == "unrar";
      config.android_sdk.accept_license = true;
      config.oraclejdk.accept_license = true;
      overlays = [
        self.overlays.default
        inputs.nix-writers.overlays.default
        (import (inputs.stockholm.inputs.nix-writers + "/pkgs"))
        (this: super: {
          inherit (this.writers) writeDash writeDashBin;
          stockholm.lib = inputs.stockholm.lib;
          ha-ara-menu = inputs.ha-ara-menu.packages.${config.nixpkgs.hostPlatform}.default;
          inventory4ce = inputs.inventory4ce.packages.${config.nixpkgs.hostPlatform}.default;
        })
        inputs.stockholm.overlays.default
      ];
    };
}
