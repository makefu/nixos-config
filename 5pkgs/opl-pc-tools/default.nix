{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, meson
, ninja
, qt5
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "OPL-PC-Tools";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "brainstream";
    repo = "OPL-PC-Tools";
    rev = version;
    sha256 = "1772j99r7ssf45512z5256142gj2ds9mgqv5m8k6hszd5jbnc9qc";
  };

  #dontUseCmakeConfigure = true;
  nativeBuildInputs = [ cmake pkg-config meson ninja 
 wrapQtAppsHook
];
buildInputs = with qt5;[ qtbase 
qttools
];

installPhase = ''
ls -lahtr .
  mkdir -p $out/bin
  cp oplpctools $out/bin/
    '';

  meta = with lib; {
    homepage = "https://github.com/joshkunz/ashuffle";
    description = "Automatic library-wide shuffle for mpd";
    maintainers = [ maintainers.tcbravo ];
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
