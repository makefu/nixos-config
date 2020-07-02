{ pkgs, ... }:{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/NUR/archive/28e5326ecbaef8b961bec7d18dbfe35f522fb2b1.tar.gz";
      sha256 = "1yni27g71r8n9bgsck7lz5dzx2fciljnba249yqhr9k3mzlkr7yb";
    }
  ){
      inherit pkgs;
    };
  };
}
