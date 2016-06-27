{ stdenv, lib, pkgs, fetchurl,fetchFromGitHub,
  libpcap, libdnet, libevent, readline, autoconf, automake, libtool, zlib, pcre,
  ... }:
stdenv.mkDerivation rec {
  name = "honeyd-${version}";

  #version = "1.5c"; #original, does not compile due to libc errors
  #src = fetchurl {
  #  url = "http://www.honeyd.org/uploads/honeyd-${version}.tar.gz";
  #  sha256 = "0vcih16fk5pir5ssfil8x79nvi62faw0xvk8s5klnysv111db1ii";
  #};

  #version = "64d087c"; # honeyd-1.6.7
  #  sha256 = "0zhnn13r24y1q494xcfx64vyp84zqk8qmsl41fq2674230bn0p31";

  version  = "c135fea08"; #nova-13.09
  src = fetchFromGitHub {
    owner = "DataSoft";
    repo = "honeyd";
    rev = version;
    sha256 = "1r9qds7a1yp3nkccwh3isrizpr2njhpf1m6qp3lqkj0i9c4w6x44";
  };

  buildInputs = with pkgs;[
    automake
    gnugrep
    libpcap
    libdnet
    pcre
    libevent
    readline
    autoconf
    libtool
    zlib
    coreutils
    python
    pythonPackages.sqlite3
  ];
  patches = [ ./fix-autogen.patch ];

  # removes user install script from Makefile before automake
  preConfigure = ''
    sed -i '/init.py$/d' Makefile.am
    sh ./autogen.sh
  '';

  makeFlags = [ "LIBS=-lz" ];
  configureFlags = [
    "--with-libpcap=${libpcap}"
    "--with-libevent=${libevent}"
    "--with-zlib=${zlib}"
    "--with-python"
    "--with-libpcre=${pcre}"
    "--with-libreadline=${readline}"
  ];

  meta = {
    homepage = http://www.honeyd.org/;
    description = "virtual Honeypots";
    license = lib.licenses.gpl2;
  };
}
