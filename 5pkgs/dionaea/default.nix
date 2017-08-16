{ stdenv, lib, pkgs, fetchurl,fetchFromGitHub,
  libpcap, libdnet, libevent, readline, autoconf, automake, libtool, zlib, pcre,
  libev,
  ... }:
let
  liblcfg = stdenv.mkDerivation rec {
    name = "liblcfg-${version}";
    version = "750bc90";
    src = fetchFromGitHub {
      owner = "ThomasAdam";
      repo = "liblcfg";
      rev = version;
      sha256 = "1k3r47p81paw5802jklx9xqbjrxr26pahipxn9nq3177qhxxibkr";
    };
    buildInputs = with pkgs;[ autoconf automake ];
    preConfigure = ''autoreconf -fi'';
    sourceRoot = "${name}-src/code";
  };
in stdenv.mkDerivation rec {
  name = "liblcfg-${version}";

  #version = "1.5c"; #original, does not compile due to libc errors
  #src = fetchurl {
  #  url = "http://www.honeyd.org/uploads/honeyd-${version}.tar.gz";
  #  sha256 = "0vcih16fk5pir5ssfil8x79nvi62faw0xvk8s5klnysv111db1ii";
  #};

  #version = "64d087c"; # honeyd-1.6.7
  #  sha256 = "0zhnn13r24y1q494xcfx64vyp84zqk8qmsl41fq2674230bn0p31";

  version  = "6756787f94c4f1ac53d1e5545d052774a0446c04";
  src = fetchFromGitHub {
    owner = "rep";
    repo = "dionaea";
    rev = version;
    sha256 = "04zjr9b7x0rqwzgb9gfxq6pclb817gz4qaghdl8xa79bqf9vv2p7";
  };

  buildInputs = with pkgs;[ libtool automake autoconf ];
  configureFlags = [
    "--with-liblcfg=${liblcfg}"
    "--with-libpcap=${libpcap}"
  ];

  meta = {
    homepage = http://www.honeyd.org/;
    description = "virtual Honeypots";
    license = lib.licenses.gpl2;
  };
}
