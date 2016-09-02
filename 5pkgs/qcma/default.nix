{ lib, stdenv, fetchFromGitHub, fetchgit, libusb, libtool, autoconf, pkgconfig, git,
gettext, automake, libxml2 , qmakeHook, makeQtWrapper,
qtbase, qttools, qtmultimedia, libnotify, ffmpeg, gdk_pixbuf }:
let
  libvitamtp = stdenv.mkDerivation rec {
    name = "libvitamtp-${version}";
    version = "2.5.9";

    src = fetchFromGitHub {
      owner = "codestation";
      repo = "vitamtp";
      rev = "v"+version;
      sha256 = "09c9f7gqpyicfpnhrfb4r67s2hci6hh31bzmqlpds4fywv5mzaf8";
    };

    buildInputs = [ libusb libxml2 libtool autoconf automake gettext pkgconfig ];
    preConfigure = "sh ./autogen.sh";

    meta = {
      description = "Content Manager Assistant for the PS Vita";
      homepage = https://github.com/codestation/qcma;
      license = stdenv.lib.licenses.gpl2;
      platforms = stdenv.lib.platforms.linux;
      maintainers = with stdenv.lib.maintainers; [ makefu ];
    };
  };
in stdenv.mkDerivation rec {
  name = "qcma-${version}";
  version = "0.3.13";

  src = fetchgit {
    url = "git://github.com/codestation/qcma.git";
    rev = "refs/tags/v"+version;
    leaveDotGit = true;
    sha256 = "164abjwlw2nw2i30wlwpsavz1zjkp6a14yprvinma5hflkw4yj6i";
  };

  preConfigure = ''
    lrelease common/resources/translations/*.ts
  '';

  # TODO: manually adding qtbase and qtmultimedia to the library path is shit,
  # this should be done somewhere before when building the project, idk.
  installPhase = ''
    make INSTALL_ROOT="$(out)" install
    for i in qcma qcma_cli; do
      wrapQtProgram $out/bin/$i --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
    qtbase qtmultimedia ]}
    done
  '';

  enableParallelBuilding = true;

  buildInputs = [ gdk_pixbuf ffmpeg libnotify libvitamtp git qtmultimedia qtbase ];
  nativeBuildInputs = [ qmakeHook qttools pkgconfig makeQtWrapper ];

  meta = {
    description = "Content Manager Assistant for the PS Vita";
    homepage = https://github.com/codestation/qcma;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
