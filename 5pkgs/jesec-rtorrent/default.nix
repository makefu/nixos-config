{
  lib,
  callPackage,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  gtest,
  ncurses,
  jsonRpcSupport ? true,
  nlohmann_json,
  xmlRpcSupport ? true,
  xmlrpc_c,
}:
let
  libtorrent = callPackage ./libtorrent.nix {};
in
stdenv.mkDerivation rec {
  pname = "jesec-rtorrent";
  version = "0.9.8-r16-unstable-2023-07-21";

  src = fetchFromGitHub {
    owner = "jesec";
    repo = "rtorrent";
    rev = "199e8f85244c8eb1c30163d51755570ad86139bb";
    hash = "sha256-AWWOvvUNNOIbNiwY/uz55iKt8A0YuMsyWGjaLgKUOCY=";
  };

  passthru = {
    inherit libtorrent;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs =
    [
      curl
      libtorrent
      ncurses
    ]
    ++ lib.optional jsonRpcSupport nlohmann_json
    ++ lib.optional xmlRpcSupport xmlrpc_c;

  cmakeFlags =
    [
      "-DUSE_RUNTIME_CA_DETECTION=NO"
    ]
    ++ lib.optional (!jsonRpcSupport) "-DUSE_JSONRPC=NO"
    ++ lib.optional (!xmlRpcSupport) "-DUSE_XMLRPC=NO";

  doCheck = true;

  nativeCheckInputs = [
    gtest
  ];

  prePatch = ''
    substituteInPlace src/main.cc \
      --replace "/etc/rtorrent/rtorrent.rc" "${placeholder "out"}/etc/rtorrent/rtorrent.rc"
  '';

  postFixup = ''
    mkdir -p $out/etc/rtorrent
    cp $src/doc/rtorrent.rc $out/etc/rtorrent/rtorrent.rc
  '';

  meta = with lib; {
    description = "Ncurses client for libtorrent, ideal for use with screen, tmux, or dtach (jesec's fork)";
    homepage = "https://github.com/jesec/rtorrent";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ winter ];
    platforms = platforms.linux;
    mainProgram = "rtorrent";
  };
}
