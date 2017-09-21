{ stdenv, bundlerEnv, ruby, fetchFromGitHub }:
# nix-shell --command "bundler install && bundix" in the clone, copy gemset.nix, Gemfile and Gemfile.lock
let
  gems = bundlerEnv {
    name = "beef-env";
    inherit ruby;
    gemdir  = ./.;
  };
in stdenv.mkDerivation {
  name = "beef-2017-09-21";
  src = fetchFromGitHub {
    owner = "beefproject";
    repo = "beef";
    rev = "69aa2a3";
    sha256 = "1rky61i0wzpwcq3kqfa0m5hf6wyz8q8jgzs7dpfh04w9qh32ic4p";
  };
  buildInputs = [gems ruby];
  installPhase = ''
    mkdir -p $out/{bin,share/beef}

    cp -r * $out/share/beef
    # set the default db path, unfortunately setting to /tmp does not seem to work
    # sed -i 's#db_file: .*#db_file: "/tmp/beef.db"#' $out/share/beef/config.yaml

    bin=$out/bin/beef
    cat > $bin <<EOF
#!/bin/sh -e
exec ${gems}/bin/bundle exec ${ruby}/bin/ruby $out/share/beef/beef "\$@"
EOF
    chmod +x $bin
  '';

  # crashes with segfault
  # also, db cannot be set
  meta.broken = true;

}
