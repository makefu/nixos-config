{ stdenv, fetchFromGitHub
, cmake
, nodejs
, git
, miniupnpc
, boost
, leveldb
, openssl
, geoip
, libmaxminddb
, websocketpp
, libnatpmp
, tbb
, bzip2
, zlib
, pkgconfig
, python
}:
stdenv.mkDerivation rec {
  name = "airdcpp-webclient-${version}";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "airdcpp-web";
    repo = "airdcpp-webclient";
    rev = version;
    sha256 = "1k07ggfw2vq1cs7smykkgkqd8wayamlw1g1mnijjvza4f3zbvihp";
  };

  nativeBuildInputs = [ cmake git nodejs pkgconfig python ];
  preConfigure =''
    echo pkgconfig: $PKG_CONFIG_PATH
    # sed -i s/find_package/pkg_search_module/ CMakeLists.txt
  '';
  buildInput = [ miniupnpc boost leveldb openssl geoip websocketpp libmaxminddb libnatpmp tbb bzip2 zlib];
  cmakeFlags = [
  "-DLIBMAXMINDDB_ROOT_DIR=${libmaxminddb}"
  "-DBZIP2_INCLUDE_DIR=${bzip2}/include"
  "-DBZIP2_LIBRARIES=${bzip2}/lib"
  "-DZLIB_INCLUDE_DIR=${zlib}/include"
  "-DZLIB_LIBRARY=${zlib}/lib"
  "-DOPENSSL_CRYPTO_LIBRARY=${openssl}/lib"
  "-DOPENSSL_INCLUDE_DIR=${openssl}/include"
  "-DMINIUPNP_LIBRARY=${miniupnpc}/lib"
  "-DMINIUPNP_INCLUDE_DIR=${miniupnpc}/include"
  "-DLevelDB_LIBRARY=${leveldb}/lib"
  "-DLevelDB_INCLUDE_DIR=${leveldb}/include"
  "-DLibNatpmp_INCLUDE_DIR=${libnatpmp}/include"
  "-DLibNatpmp_LIBRARY=${libnatpmp}/lib"
  "-DBoost_INCLUDE_DIR=${boost.dev}/include"
  "-DBoost_LIBRARY=${boost}/lib"
  "-DWebsocketpp_INCLUDE_DIR=${websocketpp}/include"
  "-DWebsocketpp_LIBRARY=${websocketpp}/lib"
  ];

  meta = with stdenv.lib; {
    description = "dcpp client";
    homepage = http://fixme;
    license = licenses.gpl3;
    maintainers = with maintainers; [ makefu ];
    platforms = with platforms; linux;
  };
}
