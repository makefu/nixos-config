{ config, ... }:

{
  nix = {
    binaryCaches = [
      "http://cache.prism.r"
    ];
    binaryCachePublicKeys = [
      "cache.prism-1:+S+6Lo/n27XEtvdlQKuJIcb1yO5NUqUCE2lolmTgNJU="
      "cache.prism-2:YwmCm3/s/D+SxrPKN/ETjlpw/219pNUbpnluatp6FKI="
    ];
  };
}
