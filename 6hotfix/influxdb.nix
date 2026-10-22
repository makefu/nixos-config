{ lib, pkgs, ... }:
let
  # 22 Oct 2026: libflux 0.196.1 (the Rust flux engine influxdb 1.x links
  # against via cgo) no longer builds with the nixpkgs-unstable rustc:
  # flux-core compiles with its `strict` feature, which turns
  # `deny(warnings)` on, and modern rustc rejects the then-valid
  # `usize::max_value()` as deprecated. The pinned nixpkgs postPatch only
  # drops missing_docs/dead_code from the deny list, not `deprecated`.
  # Copy of nixpkgs by-name/in/influxdb with the libflux sub-build
  # patched to the non-deprecated MAX/MIN constants. Drop this hotfix
  # once nixpkgs ships a fixed influxdb 1.x derivation.
  libflux_version = "0.196.1";

  flux = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "libflux";
    version = libflux_version;
    src = pkgs.fetchFromGitHub {
      owner = "influxdata";
      repo = "flux";
      tag = "v${libflux_version}";
      hash = "sha256-935aN2SxfNZvpG90rXuqZ2OTpSGLgiBDbZsBoG0WUvU=";
    };
    patches = [
      # https://github.com/influxdata/flux/pull/5542
      ./fix-unsigned-char.patch
    ];

    # Upstream rewrite (keep): don't fail on missing docs / dead_code.
    # Hotfix: migrate the deprecated numeric associated functions that
    # newer rustc rejects under the strict deny(warnings) build.
    postPatch = ''
      substituteInPlace flux-core/src/lib.rs \
        --replace-fail "deny(warnings, missing_docs))]" "deny(warnings), allow(dead_code, mismatched_lifetime_syntaxes, unused_assignments))]"
      # pipefail makes a no-match grep kill the phase; || true guards it.
      grep -rl 'usize::max_value()' . | { xargs -r sed -i 's/usize::max_value()/usize::MAX/g'; } || true
      grep -rl 'usize::min_value()' . | { xargs -r sed -i 's/usize::min_value()/usize::MIN/g'; } || true
    '';
    sourceRoot = "${finalAttrs.src.name}/libflux";

    cargoHash = "sha256-A6j/lb47Ob+Po8r1yvqBXDVP0Hf7cNz8WFZqiVUJj+Y=";
    nativeBuildInputs = [ pkgs.rustPlatform.bindgenHook ];
    buildInputs = lib.optional pkgs.stdenv.hostPlatform.isDarwin pkgs.libiconv;
    pkgcfg = ''
      Name: flux
      Version: ${libflux_version}
      Description: Library for the InfluxData Flux engine
      Cflags: -I/out/include
      Libs: -L/out/lib -lflux -lpthread
    '';
    postInstall = ''
      mkdir -p $out/include $out/pkgconfig
      cp -r $NIX_BUILD_TOP/source/libflux/include/influxdata $out/include
      printf "%s" "$pkgcfg" > $out/pkgconfig/flux.pc
      substituteInPlace $out/pkgconfig/flux.pc \
        --replace-fail /out $out
    ''
    + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      install_name_tool -id $out/lib/libflux.dylib $out/lib/libflux.dylib
    '';

    __structuredAttrs = true;
  });
in
{
  # influxdb stays enabled everywhere it is imported; only the package
  # gets swapped for the libflux-hotfixed copy. passthru.flux exposes the
  # libflux sub-build so the hotfix can be verified standalone.
  # Drop this file once nixpkgs ships a fixed influxdb 1.x.
  services.influxdb.package = lib.mkOverride 90 (pkgs.buildGoModule (finalAttrs: {
    pname = "influxdb";
    version = "1.12.2";

    src = pkgs.fetchFromGitHub {
      owner = "influxdata";
      repo = "influxdb";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Q05mKmAXxrk7IVNxUD8HHNKnWCxmNCdsr6NK7d7vOHM=";
    };

    vendorHash = "sha256-+6fOq/2YVz74Loy1pVLVRTr4OQm/fEBNtHy3+FQn51A=";

    nativeBuildInputs = [ pkgs.pkg-config ];

    env.PKG_CONFIG_PATH = "${flux}/pkgconfig";

    # Check that libflux is at the right version
    preBuild = ''
      flux_ver=$(grep github.com/influxdata/flux go.mod | awk '{print $2}')
      if [ "$flux_ver" != "v${libflux_version}" ]; then
        echo "go.mod wants libflux $flux_ver, but nix derivation provides ${libflux_version}"
        exit 1
      fi
    '';

    doCheck = false;

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${finalAttrs.version}"
    ];

    excludedPackages = "test";

    meta = {
      description = "Open-source distributed time series database";
      license = lib.licenses.mit;
      homepage = "https://influxdata.com/";
      maintainers = with lib.maintainers; [ zimbatm ];
    };

    passthru.flux = flux;
  }));
}
