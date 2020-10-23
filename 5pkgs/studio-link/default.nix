{ stdenv
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
  version = "20.05.5";

  src = fetchurl {
    url = "https://download.studio.link/releases/v${version}-stable/linux/studio-link-standalone-v${version}.tar.gz";
    sha256 = "0wmcvihyxf4xvgrspvy3qhhabczv86hdfcfq61jv51hfrzibc2q1";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  sourceRoot = ".";
  buildInputs = [
    alsaLib
    openssl
    zlib
    libjack2
    pulseaudio
  ];


  installPhase = ''
    install -m755 -D studio-link-standalone-v${version} $out/bin/studio-link
  '';

  meta = with stdenv.lib; {
    homepage = https://studio-link.com;
    description = "Voip transfer";
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };
}
