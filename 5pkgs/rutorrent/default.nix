{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "rutorrent-src-3.7";
  src = pkgs.fetchFromGitHub {
    owner = "Novik";
    repo = "rutorrent";
    rev = "b727523a153454d4976f04b0c47336ae57cc50d5";
    sha256 = "0s5wa0jnck781amln9c2p4pc0i5mq3j5693ra151lnwhz63aii4a";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r $src $out
  '';
}
