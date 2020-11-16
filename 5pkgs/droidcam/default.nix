{ stdenv, fetchFromGitHub
, pkg-config
, alsaLib
, libjpeg_turbo
, ffmpeg
, libusbmuxd
, speex
, gtk3
, libappindicator-gtk3
}:

stdenv.mkDerivation rec {
  pname = "droidcam";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "aramg";
    repo = "droidcam";
    rev = "v${version}";
    sha256 = "1d9qpnmqa3pfwsrpjnxdz76ipk4w37bbxyrazchh4vslnfc886fx";
  };

  sourceRoot = "source/linux";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    alsaLib
    libjpeg_turbo
    ffmpeg
    libusbmuxd
    speex
    gtk3
    libappindicator-gtk3
  ];

  buildPhase = ''
    runHook preBuild
    make JPEG_DIR="" JPEG_INCLUDE="" JPEG_LIB="" JPEG="$(pkg-config --libs --cflags libturbojpeg)"
  '';
  installPhase = ''
    runHook preInstall
    install -Dm755 "droidcam" "$out/bin/droidcam"
    install -Dm755 "droidcam-cli" "$out/bin/droidcam-cli"
    install -Dm644 icon2.png "$out/share/pixmaps/droidcam.png"
    install -Dm644 README.md "$out/share/licenses/droidcam/LICENSE"
  '';

  meta = with stdenv.lib; {
    description = "A kernel module to create V4L2 loopback devices";
    homepage = "https://github.com/aramg/droidcam";
    license = licenses.gpl2;
    maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
  };
}
