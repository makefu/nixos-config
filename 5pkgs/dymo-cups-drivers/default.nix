{ stdenv, lib, pkgs, fetchurl, cups, ... }:

stdenv.mkDerivation rec {
  name = "dymo-cups-drivers-${version}";
  version = "1.4.0";
  src = fetchurl {
    url = "http://download.dymo.com/dymo/Software/Download%20Drivers/Linux/Download/${name}.tar.gz";
    sha256 = "0wagsrz3q7yrkzb5ws0m5faq68rqnqfap9p98sgk5jl6x7krf1y6";
  };
  buildInputs = [ cups ];
  makeFlags = [ "cupsfilterdir=$(out)/lib/cups/filter" "cupsmodeldir=$(out)/share/cups/model" ];

  # acd_cli gets dumped in bin and gets overwritten by fixupPhase
  meta = {
    description = "Dymo printer drivers";
  };
}
