{ lib, stdenv, fetchurl, makeWrapper, wrapGAppsHook, glib , jdk19 }:
let
    jre = jdk19.override { enableJavaFX = true; };
in

stdenv.mkDerivation rec {
  name = "ns-usbloader-${version}";
  version = "7.0";

  src = fetchurl {
    url = "https://github.com/developersu/ns-usbloader/releases/download/v${version}/ns-usbloader-${version}.jar";
    sha256 = "sha256-8RtzUcNVuGRJuLwUibSUH0RWnqC4h3F/c59P++C8gMM=";
  };


  buildInputs = [ jre ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -D $src $out/ns-usbloader/ns-usbloader.jar
    makeWrapper ${jre}/bin/java $out/bin/ns-usbloader \
      --add-flags "-jar $out/ns-usbloader/ns-usbloader.jar"
    runHook postInstall
  '';
  nativeBuildInputs = [ glib wrapGAppsHook makeWrapper ];


  meta = with lib; {
    description = "Awoo Installer and GoldLeaf uploader of the NSPs (and other files), RCM payload injector, application for split/merge files";
    homepage = https://github.com/developersu/ns-usbloader;
    maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
    license = with licenses; [ gpl3 ];
  };

}
