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
, ghostscript
, a2ps
, wget
, file
, foomatic-filters
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "foomatic-db-engine";
  version = "2020-01-31";

  src = fetchFromGitHub {
    owner = "OpenPrinting";
    repo = "foomatic-db-engine-4";
    rev = "bd265b77a9f66f672bf1e3f0803145f2eccabf06";
    sha256 = "1f53kd3b0sxgx7hg2dvw2624bpwdfcx0zh4dn0h89l84mirgw1bs";
  };

  nativeBuildInputs = [
    autoreconfHook
    perl
    makeWrapper
  ];
  postConfigure = ''
    sed -i "s#$ENV{BINDIR}#${placeholder "out"}/bin#" makeDefaults
  '';
  configureFlags = [
    #"PERL_INSTALLDIRS=vendor"
    "PERL_INSTALLDIRS=site"
    "--prefix=/"
    "PERLPREFIX=/"
    #"DESTDIR=$(out)"
    #"sysconfdir=/etc"
    "LIBDIR=/lib"
    #"PERL_INSTALLDIRS=site"
    #"PERL_INSTALLDIRS=perl"
    #PERL_INSTALLDIRS=perl"
    "PERL=${perl}/bin/perl"
    "FILEUTIL=${file}/bin/file"
    "SBINDIR=/bin"
  ];
  makeFlags = [ 
    "DESTDIR=${placeholder "out"}" 
    "PERLLIB=$(out)/${perlPackages.perl.libPrefix}"
  ];

  buildInputs = [
    cups
    ghostscript
    a2ps
    wget
    perl
    libxml2
    file
    foomatic-filters
  ];
  postFixup = ''
    echo cups > "$out"/etc/foomatic/defaultspooler

    for file in $out/bin/foomatic-*;do
        wrapProgram "$file" \
          --set PERL5LIB "$out/${perlPackages.perl.libPrefix}" \
          --prefix PATH : "$out/bin"
    done

  '';
  
  meta = with lib; {
    description = "Command line tool to print labels on Brother P-Touch printers on Linux";
    license = licenses.gpl3Plus;
    homepage = "https://mockmoon-cybernetics.ch/computer/p-touch2430pc/";
    maintainers = with maintainers; [ shamilton ];
    platforms = platforms.linux;
  };
}
