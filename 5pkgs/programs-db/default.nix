{ stdenv }:

stdenv.mkDerivation rec {
  name = "programs-db";
  src = builtins.fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz ;

  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    cp programs.sqlite $out
  '';

}
