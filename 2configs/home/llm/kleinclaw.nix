{
  self,
  pkgs,
  ...
}:
let
  kleinclaw-src = self.inputs.kleinclaw;

  # kleinclaw is an OpenClaw plugin and opencrow only loads omp extensions,
  # so we skip the plugin layer entirely and package the embedded miniclaw
  # CLI (the runtime that actually talks to kleinanzeigen.de). The agent
  # drives it from the shell, guided by the helper skill below.
  miniclaw = pkgs.buildNpmPackage {
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
  };
in
{
  services.opencrow.skills.kleinanzeigen-helper =
    "${kleinclaw-src}/skills/kleinanzeigen-helper-skill";

  # chromium: miniclaw publish/verify operations drive a real browser.
  services.opencrow.extraPackages = [
    miniclaw
    pkgs.chromium
  ];

  # Workspace for the miniclaw config.yaml + ad drafts. Bootstrapping the
  # config (and the kleinanzeigen login) is a runtime step done by the agent.
  containers.opencrow.config.systemd.tmpfiles.rules = [
    "d /var/lib/opencrow/kleinanzeigen 0750 opencrow opencrow -"
  ];
}
