{ pkgs, ... }:
pkgs.buildNpmPackage rec {
  pname = "pageres-cli";
  version = "8.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "sindresorhus";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/gxa+veo+ycTmXWayMoyzlB777MPA0xYszNgreFu3Sk";
  };
  buildInputs = [ pkgs.chromium pkgs.makeWrapper ];
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  postInstall = ''
    wrapProgram $out/bin/pageres \
      --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromium}/bin/chromium \
      --set PUPPETEER_SKIP_DOWNLOAD true
  '';

  PUPPETEER_SKIP_DOWNLOAD = true;
  dontNpmBuild = true;
  dontNpmPrune = true;

  npmDepsHash = "sha256-ev6TGqlddzdkV5bpUDA1T1vv2/A00IfXA3Q/HHFJW7A";
}
