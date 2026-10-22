{ lib, ... }:
let
  # 21 Oct 2026 security releases for CVE-2026-109618 and CVE-2026-109619.
  patched = {
    php83 = {
      version = "8.3.36";
      hash = "sha256-RvS0XjaI7SsYGQFae1MsFbUcwFW907E/0A3f7r7tzV8=";
    };
    php84 = {
      version = "8.4.27";
      hash = "sha256-slMKh3xyL0sIyeF0owywi6wrfhkD7m6eMV8KqfX4LCQ=";
    };
    php85 = {
      version = "8.5.12";
      hash = "sha256-/7YO3EN87WO1E35JhNs3moERxQBJxxFRDYuVgnfvwag=";
    };
  };

  # Drop regression tests which do not reproduce deterministically inside the
  # Nix build sandbox:
  # - filter OOM tests (need host memory pressure)
  # - pcntl cpuaffinity tests (assert cpus 0..1 are settable; fail on builders
  #   with a single online cpu or a restricted affinity mask — EXTENSIONS
  #   skipif only checks function availability, not topology)
  mkPatchedSrc = prev: { version, hash }:
    let
      src = prev.fetchurl {
        url = "https://www.php.net/distributions/php-${version}.tar.bz2";
        inherit hash;
      };
    in
    prev.runCommand "php-${version}-src" { } ''
      mkdir -p "$out"
      tar -xf ${src} -C "$out" --strip-components=1
      rm -f "$out"/ext/filter/tests/oom_filter_input.phpt \
            "$out"/ext/filter/tests/oom_filter_input_array.phpt \
            "$out"/ext/filter/tests/oom_filter_default_encoded.phpt \
            "$out"/ext/pcntl/tests/pcntl_cpuaffinity.phpt \
            "$out"/ext/pcntl/tests/pcntl_cpuaffinity_bound.phpt
    '';

  mkPhpOverride = name: attrs: _final: prev: {
    ${name} = prev.${name}.overrideAttrs (_: {
      inherit (attrs) version;
      src = mkPatchedSrc prev attrs;
    });
  };
in
{
  # mkAfter keeps this overlay last so it wins over any other PHP override.
  nixpkgs.overlays = lib.mkAfter (map (name: mkPhpOverride name patched.${name}) (builtins.attrNames patched));
}
