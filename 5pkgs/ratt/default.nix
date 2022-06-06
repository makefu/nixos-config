{ buildGoModule, fetchFromSourcehut, lib }:
buildGoModule rec {
  pname = "ratt";
  version = "unstable-2022-05-09";

  src = fetchFromSourcehut {
    owner = "~ghost08";
    repo = "ratt";
    rev = "bf539e1cb04017f5e9d248a8e5f7a6f22f77d06e";
    sha256 = "0pfz6wnmpwabklayah3bddxkhvg64f5hfyvzkv3xfqpw8c70jdll";
  };

  proxyVendor = true;
  vendorSha256 = "0wf299i5z86gysrcmgd5x6zq589qn7h69k1sz4xl5yrhn53mdsq0";

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
