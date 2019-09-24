{ go_1_12, buildGoPackage, fetchFromGitHub }:
let
  builder = buildGoPackage.override { go = go_1_12; };
in
builder rec {
  name = "shiori-${version}";
  version = "1.6.0-master";
  goPackagePath = "github.com/go-shiori/shiori";
  src = fetchFromGitHub {
    owner = "go-shiori";
    repo = "shiori";
    rev = "c77b17caf8fcdf336adea33d0e4ac7ab13c10bc5";
    sha256 = "11c5yxkmawwpswk256d151ixmj1vlnhrhsbfp9xan1v5cbqpkxdm";
  };
  goDeps = ./deps.nix;
}
