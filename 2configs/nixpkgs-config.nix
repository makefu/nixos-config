{lib, pkgs, self, inputs, config, ... }:{
    nixpkgs = {
      config.allowUnfree = true;
      config.packageOverrides = pkgs: {
        tinc = pkgs.tinc_pre;
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      };
      config.allowUnfreePredicate = pkg: lib.packageName pkg == "unrar";
      config.android_sdk.accept_license = true;
      config.oraclejdk.accept_license = true;
      config.permittedInsecurePackages = [ "intel-media-sdk-23.2.2" "libsoup-2.74.3" "olm-3.2.16"];
      overlays = [
        self.overlays.default
        inputs.nix-writers.overlays.default
        (import (inputs.stockholm.inputs.nix-writers + "/pkgs"))
        (this: super: {
          inherit (this.writers) writeDash writeDashBin;
          stockholm.lib = inputs.stockholm.lib;
          ha-ara-menu = inputs.ha-ara-menu.packages.${pkgs.stdenv.hostPlatform}.default;
          inventory4ce = inputs.inventory4ce.packages.${pkgs.stdenv.hostPlatform}.default;
        })
        inputs.stockholm.overlays.default
        inputs.mediawiki-matrix-bot.overlays.default
      ];
    };
}
