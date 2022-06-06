{ lib, stdenv
, fetchgit
, cmake
, gd
, git
, libusb1
, gettext
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "ptouch-print";
  version = "1.5-master";

  src = fetchgit {
    url = "https://git.familie-radermacher.ch/cgi/cgit/linux/ptouch-print.git";
    rev = "674e0da5fb6254c4f015c6c910377b6f4f04e0f3";
    sha256 = "04a3kp01mvf538l9d6bw2b54azn64xh605qwaq1ig8imjphrn82s";
  };

  nativeBuildInputs = [
    cmake
    git
  ];

  installPhase = ''
    install -D ptouch-print $out/bin/ptouch-print
    install -D $src/ptouch-print.1 $out/share/man/man1/ptouch-print.1
  '';

  buildInputs = [
    gd
    pkg-config
    gettext
    libusb1
  ];

  meta = with lib; {
    description = "Command line tool to print labels on Brother P-Touch printers on Linux";
    license = licenses.gpl3Plus;
    homepage = "https://mockmoon-cybernetics.ch/computer/p-touch2430pc/";
    maintainers = with maintainers; [ shamilton ];
    platforms = platforms.linux;
  };
}
