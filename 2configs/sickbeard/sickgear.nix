{ stdenv, fetchFromGitHub, python37, makeWrapper }:

let
  pythonEnv = python37.withPackages(ps: with ps; [
    (ps.callPackage ./cheetah3.nix {})
  ]);
in stdenv.mkDerivation rec {
  pname = "sickgear";
  #version = "0.21.6";
  version = "0.21.21";

  src = fetchFromGitHub {
    owner = "SickGear";
    repo = "SickGear";
    rev = "release_${version}";
    sha256 = "15nlxg2867l846qqxklmfyqmn5nc01ksd4lpwbrbjdzpk4y3xi78";
  };

  dontBuild = true;
  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pythonEnv ];
  patches = [ ./debug.patch ];

  installPhase = ''
    mkdir -p $out/bin
    cp -R {autoProcessTV,gui,lib,sickbeard,sickgear.py,SickBeard.py} $out/

    makeWrapper $out/sickgear.py $out/bin/sickgear
  '';

  meta = with stdenv.lib; {
    description = "The most reliable stable TV fork of the great Sick-Beard to fully automate TV enjoyment with innovation";
    license     = licenses.gpl3;
    homepage    = "https://github.com/SickGear/SickGear";
    maintainers = with stdenv.lib.maintainers; [ rembo10 ];
  };
}
