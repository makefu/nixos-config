# miniclaw CLI packaged standalone so agent.nix can put it on the container
# PATH without importing kleinclaw.nix (which reads config.services.hermes-agent
# and would circular-import through agent.nix).
{ self, pkgs }:
let
  kleinclaw-src = self.inputs.kleinclaw;
in
pkgs.buildNpmPackage {
  pname = "miniclaw";
  version = "0.2.2";
  src = kleinclaw-src;
  npmDepsHash = "sha256-TGHYpyB1RZtkz3AtoO4k72XJD/e9CUOvhvK5gdZZ2C4=";
  # miniclaw/dist is prebuilt and committed upstream; the npm build script
  # only re-runs tsc and would pull in devDependencies.
  dontNpmBuild = true;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postInstall = ''
    mkdir -p $out/bin
    # bin entry lives in the miniclaw sub-package which npm does not link;
    # wrap it manually. npm deps (yaml, glob, decimal.js) resolve upwards
    # to lib/node_modules/kleinclaw/node_modules.
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/miniclaw \
      --add-flags "$out/lib/node_modules/kleinclaw/miniclaw/dist/cli.js"
  '';
}
