{
  # ln -s /run/current-system/sw/bin/xsane ~/.gimp-2.8/plug-ins/xsane
  nixpkgs.config.packageOverrides = pkgs: {
    xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
  };
}

