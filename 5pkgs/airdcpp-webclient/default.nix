{ stdenv, fetchurl
}:
stdenv.mkDerivation rec {
  name = "airdcpp-webclient-${version}";
  version = "2.3.0";
  
  src = fetchurl {
    url = http://web-builds.airdcpp.net/stable/airdcpp_2.3.0_webui-2.3.0_64-bit_portable.tar.gz;
    sha256 = "0yvcl0nc70fghc7vfsgvbpryi5q97arld8adql4way4qa0mdnyv1";
  };

  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out/{share,bin}
    cp -r *  $out/share
    ln -s $out/share/airdcppd $out/bin/
  '';

  meta = with stdenv.lib; {
    # to start it: airdcpp -p=<pid-file> -c=<config-store-path (must be writeable)> --configure
    description = "dcpp client (statically precompiled)";
    homepage = http://fixme;
    license = licenses.gpl3;
    maintainers = with maintainers; [ makefu ];
    platforms = with platforms; linux;
  };
}
