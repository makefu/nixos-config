{ stdenv
, lib
, fetchurl
, alsa-lib
, unzip
, openssl
, zlib
, libjack2
, pulseaudio
, autoPatchelfHook
, python3
}:

stdenv.mkDerivation rec {
  name = "studio-link-${version}";
  version = "21.07.0";

  src = fetchurl {
    url = "https://download.studio.link/releases/v${version}-stable/linux/studio-link-standalone-v${version}.tar.gz";
    hash = "sha256-4CkijAlenhht8tyk3nBULaBPE0GBf6DVII699/RmmWI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    python3
  ];
  sourceRoot = ".";
  buildInputs = [
    alsa-lib
    openssl
    zlib
    pulseaudio
  ];


  installPhase = ''
    install -m755 -D studio-link-standalone-v${version} $out/bin/studio-link
    python3 ${./patch-webui.py} $out/bin/studio-link
  '';

  meta = with lib; {
    homepage = https://studio-link.com;
    description = "Voip transfer";
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };
}
