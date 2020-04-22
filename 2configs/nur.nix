{ pkgs, ... }:{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/NUR/archive/b7f7e072b3fa56aa0d86dfe3689cb13f0615bbbe.tar.gz";
      sha256 = "0slxxg3r460aa1rc83j0rklmr0i1hyzfbjy0kn30fyh1l3lqb22m";
    }
  ){
      inherit pkgs;
    };
  };
}
