{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  proj = "u3-tool";
  name = "${proj}-${version}";
  version = "0.3";

  enableParallelBuilding = true;

  src = fetchurl {
    url = "mirror://sourceforge/${proj}/${name}.tar.gz";
    sha256 = "1p9c9kibd1pdbdfa0nd0i3n7bvzi3xg0chm38jg3xfl8gsn0390f";
  };

  meta = {
    description = "Tool for controlling the special features of a 'U3 smart drive' USB Flash disk.";
    homepage = https://sourceforge.net/projects/u3-tool/ ;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
