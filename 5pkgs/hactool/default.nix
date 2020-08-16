{ lib, stdenv,  fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "hactool";
  name = "${pname}-${version}";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "SciresM";
    repo = "hactool";
    rev = version;
    sha256 = "0305ngsnwm8npzgyhyifasi4l802xnfz19r0kbzzniirmcn4082d";
  };
  preBuild = ''
    cp config.mk.template config.mk
  '';
  installPhase = ''
    install -D hactool $out/bin/hactool
  '';
  buildInputs = [ ];
  nativeBuildInputs = [ ];

  meta = {
    description = "PulseAudio volumene meter";
    homepage = http://0pointer.de/lennart/projects/pavumeter;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
