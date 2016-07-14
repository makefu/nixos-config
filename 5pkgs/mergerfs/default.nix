{ stdenv, fetchgit, fuse, pkgconfig, which, attr, pandoc, git }:

stdenv.mkDerivation rec {
  name = "mergerfs-${version}";
  version = "2.14.0";

  # not using fetchFromGitHub because of changelog being built with git log
  src = fetchgit {
    url = "https://github.com/trapexit/mergerfs";
    rev = "refs/tags/${version}";
    sha256 = "0j5r96xddlj5gp3n1xhfwjmr6yf861xg3hgby4p078c8zfriq5rm";
    deepClone = true;
  };

  buildInputs = [ fuse pkgconfig which attr pandoc git ];

  makeFlags = [ "PREFIX=$(out)" "XATTR_AVAILABLE=1" ];


  meta = {
    homepage = https://github.com/trapexit/mergerfs;
    description = "a FUSE based union filesystem";
    license = stdenv.lib.licenses.isc;
    maintainers = [ stdenv.lib.maintainers.makefu ];
  };
}
