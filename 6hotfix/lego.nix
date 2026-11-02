{ lib, ... }:
# 2 Nov 2026: the netcupv1 DNS-01 provider (new netcup CloudDNS API, used by
# security.acme.certs.*.dnsProvider for cert-relay) landed in lego v5.6.0;
# pinned nixpkgs 0bb2eedc20e4 ships 5.5.1. Replicates the open nixpkgs PR
# https://github.com/NixOS/nixpkgs/pull/572080. Drop once nixpkgs-unstable
# carries the bump.
{
  nixpkgs.overlays = lib.mkAfter [
    (_final: prev: {
      lego = prev.lego.overrideAttrs (_: {
        version = "5.6.0";
        src = prev.fetchFromGitHub {
          owner = "go-acme";
          repo = "lego";
          tag = "v5.6.0";
          hash = "sha256-YC6rrsRjlKYllv60mWFMlTNp8OgPGDA4Wi9/ALknkRg=";
        };
        vendorHash = "sha256-S7aJVA1YvgUB9q+hCuwQCOFdDrNI/uQ3v5n6uiHIT/4=";
      });
    })
  ];
}
