{stdenv, lib, alsaToolTarget,fetchurl, alsa-lib, ncurses, fltk13, gtk3}:

stdenv.mkDerivation rec {
  name = "alsa-${alsaToolTarget}-${version}";
  alsaToolsName = "alsa-tools-${version}";
  version = "1.0.29";

  src = fetchurl {
    urls = [
      "ftp://ftp.alsa-project.org/pub/tools/${alsaToolsName}.tar.bz2"
      "http://alsa.cybermirror.org/tools/${alsaToolsName}.tar.bz2"

    ];
    sha256 = "1lgvyb81md25s9ciswpdsbibmx9s030kvyylf0673w3kbamz1awl";
  };
  sourceRoot = "${alsaToolsName}/${alsaToolTarget}/";
  buildInputs = [ alsa-lib fltk13 gtk3 ncurses ];

  meta = {
    homepage = http://www.alsa-project.org/;
    description = "ALSA tools - ${name}";

    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.makefu ];
  };
}
