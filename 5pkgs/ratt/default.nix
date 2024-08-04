{ buildGoModule, fetchFromSourcehut, lib }:
buildGoModule rec {
  pname = "ratt";
  version = "unstable-2023-10-28";

  src = fetchFromSourcehut {
    owner = "~makefu";
    repo = "ratt";
    rev = "351e0c2c03b8663332b3a2081763edcdd13aeb22";
    sha256 = "sha256-eeW8hGMrcAD2VCWyiaJ7T7Tyhd9LlokyiALCFJj2P4I=";
  };

  proxyVendor = true;
  vendorHash = "sha256-aTsQyN+5OKApGI4ckSrQEkkXpBcvuz1ghQ5FwASNzOs=";

  # tests try to access the internet to scrape websites
  doCheck = false;

  meta = with lib; {
    description = "A tool for converting websites to rss/atom feeds";
    homepage = "https://git.sr.ht/~ghost08/ratt";
    license = licenses.mit;
    maintainers = with maintainers; [ kmein ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
