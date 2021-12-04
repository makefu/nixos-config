{ stdenv
, lib
, fetchurl
, alsaLib
, unzip
, openssl
, zlib
, libjack2
, pulseaudio
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  name = "studio-link-${version}";
  version = "21.03.2";

  src = fetchurl {
    url = "https://download.studio.link/releases/v${version}-stable/linux/studio-link-standalone-v${version}.tar.gz";
    sha256 = "0szaym9lrkbnwxaffab9snlsij6kkwlin70d36bm3vi2la8iayc6";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  sourceRoot = ".";
  buildInputs = [
    alsaLib
    openssl
    zlib
    pulseaudio
  ];


  installPhase = ''
    install -m755 -D studio-link-standalone-v${version} $out/bin/studio-link
  '';

  meta = with lib; {
    homepage = https://studio-link.com;
    description = "Voip transfer";
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };
}
