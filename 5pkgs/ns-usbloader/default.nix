{ lib, stdenv, fetchurl, makeWrapper, jre }:

stdenv.mkDerivation rec {
  name = "ns-usbloader-${version}";
  version = "5.2";

  src = fetchurl {
    url = "https://github.com/developersu/ns-usbloader/releases/download/v${version}/ns-usbloader-${version}.jar";
    sha256 = "06kzshlvqfwcjjddzqqgq13pqa5qjlajpyn6ksqxy5p5hgarj6i6";
  };


  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -D $src $out/ns-usbloader/ns-usbloader.jar
    makeWrapper ${jre}/bin/java $out/bin/ns-usbloader \
      --add-flags "-jar $out/ns-usbloader/ns-usbloader.jar"
    runHook postInstall
  '';


  meta = with lib; {
    description = "Awoo Installer and GoldLeaf uploader of the NSPs (and other files), RCM payload injector, application for split/merge files";
    homepage = https://github.com/developersu/ns-usbloader;
    maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
    license = with licenses; [ gpl3 ];
  };

}
