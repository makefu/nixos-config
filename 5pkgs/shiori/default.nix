{ buildGoPackage, fetchFromGitHub }:
let
  builder = buildGoPackage;
in
builder rec {
  name = "shiori-${version}";
  version = "1.6.0-warc";
  goPackagePath = "github.com/go-shiori/shiori";
  src = fetchFromGitHub {
    owner = "go-shiori";
    repo = "shiori";
    rev = "83f133dd07bf661d3c4cf03043392100da489559";
    sha256 = "02b17hjbh4w0ip0snd8hmdjmbc2w1pv9sws9cf9r8w09c225nw2i";
  };
  goDeps = ./deps.nix;
}
