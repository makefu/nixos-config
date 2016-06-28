{ stdenv, lib, pkgs, fetchurl,fetchFromGitHub,
  libpcap, libdnet, libevent, readline, autoconf, automake, libtool, zlib, pcre,
  ... }:
stdenv.mkDerivation rec {
  name = "farpd-${version}";


  version  = "0.2";
  src = fetchurl {
    url = https://launchpad.net/ubuntu/+archive/primary/+files/farpd_0.2.orig.tar.gz ;
    sha256 = "1m3pynvynr4vgkwh7z5i0yqlang2y0ph32cys3vbi2hx2apk9abd";
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
  patches = [
    ./farpd_0.2-11.diff
  ];
  # removes user install script from Makefile before automake
  #patches = [ ./autoconf.patch ];
  preConfigure = ''
    autoreconf -fi

    substituteInPlace configure \
      --replace "libpcap.a" "libpcap.so" \
      --replace "libevent.a" "libevent.so" \
      --replace "net/bpf.h" "pcap/bpf.h"
  '';

  makeFlags = [ "LIBS=-lz" ];
  configureFlags = [
    "--with-libpcap=${libpcap}"
    "--with-libevent=${libevent}"
    "--with-libdnet=${libdnet}"
  ];
  postInstall = ''
    mv $out/sbin/arpd $out/sbin/farpd
    mv $out/share/man/man8/arpd.8 $out/share/man/man8/farpd.8
  '';

  meta = {
    homepage = https://launchpad.net/ubuntu/+source/farpd/ ;
    description = "fake arp";
    license = lib.licenses.gpl2;
  };
}
