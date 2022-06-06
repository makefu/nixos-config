{ lib, stdenv
, fetchFromGitHub
, autoreconfHook
, gd
, libusb1
, cups
, libpng
, perl
, perlPackages
, libxml2
, callPackage
, foomatic-db-engine ? ( callPackage ../foomatic-db-engine {} )
}:

stdenv.mkDerivation rec {
  pname = "printer-driver-ptouch";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "philpem";
    repo = "printer-driver-ptouch";
    rev = "v${version}";
    sha256 = "1c4hkncnr4qwkbz5dfvksngvq057j6xnbi1jjvchnlr7zgj7cndk";
  };

  postPatch = ''
    patchShebangs foomaticalize
    '';
  nativeBuildInputs = [
    autoreconfHook
    perl
    libxml2
    perlPackages.XMLLibXML
    foomatic-db-engine
  ];
  
  buildInputs = [
    cups
    libpng
  ];
  postInstall = ''
    mkdir -p $out/share/cups/model/
    echo "dummy dummy" > "$out/share/foomatic/db/oldprinterids"
    FOOMATICDB="$out/share/foomatic" foomatic-compiledb -t ppd -d "$out/share/cups/model/Brother/"
    rm -r $out/share/foomatic
  '';
  
  meta = with lib; {
    description = "Command line tool to print labels on Brother P-Touch printers on Linux";
    license = licenses.gpl3Plus;
    homepage = "https://mockmoon-cybernetics.ch/computer/p-touch2430pc/";
    maintainers = with maintainers; [ shamilton ];
    platforms = platforms.linux;
  };
}
