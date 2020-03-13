{ stdenv, fetchFromGitHub, python3, makeWrapper }:

let
  pythonEnv = python3.withPackages(ps: with ps; [
    (python3.pkgs.callPackage ./cheetah3.nix {})
  ]);
in stdenv.mkDerivation rec {
  pname = "sickgear";
  #version = "0.21.6";
  version = "0.21.7";

  src = fetchFromGitHub {
    owner = "SickGear";
    repo = "SickGear";
    rev = "hotfix/${version}";
    sha256 = "0kj8l6xq7vycr6d15lxybnk02b39z0zk4jzy0b2lbapgk0kx3ims";
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
