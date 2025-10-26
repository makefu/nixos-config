{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  stdenvNoCC,
  pkgs,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mediatracker";
  version = "0.2.11";

  src = fetchFromGitHub {
    owner = "bonukai";
    repo = "MediaTracker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AiDVMQv9yvTaN7A9CtPZf67H8zKXTZSnlUlBXhfMEeo=";
};
    frontend = buildNpmPackage {
        pname = "${finalAttrs.pname}-client";
        inherit (finalAttrs) version src;
        sourceRoot = "source/client";
      preBuild = ''
		  echo "linking mediatracker-api from backend"
            ln -snf ${finalAttrs.backend}/lib/node_modules/mediatracker-api node_modules/mediatracker-api
            sed -i s#../server/public#./public# webpack.common.ts
        '';

        installPhase = ''
            mkdir -p $out/lib/
            cp -r public $out/lib/mediatracker-client
        '';
        npmDepsHash = "sha256-OzFV3rQt9z4qcblSiGvRQQ9L8L4gIIeACbDe1OI0n0k=";
        npmFlags = [ "--legacy-peer-deps" ];
          nativeBuildInputs = [
              pkgs.breakpointHook
          ];
    };
    backend = buildNpmPackage {
        pname = "${finalAttrs.pname}-server";
        inherit (finalAttrs) version src;
        npmDepsHash = "sha256-U+mpoVnMK8WBuIAI5ooPwBeeELeH//xZZP2KLhuXEm0=";
      dontNpmPrune = true;
        patches = [
            ./public_path_env.patch
        ];
        # sourceRoot cannot be used because server compiles data in rest-api which is readOnly otherwise
        buildPhase = ''
          cd server
          npm run build
      '';

      prePatch = ''
          cp -vf ./server/package.json ./package.json
          cp -vf ./server/package-lock.json ./package-lock.json
      '';

      preInstall = ''
          echo "preparing node_modules in server subdir"
          rm -rf node_modules
          mv ../node_modules node_modules
      '';
      # mediatracker-api is required by client but can only be built with the dependencies of backend
      # the package is provided by the backend to the frontend via node_modules
      postInstall = ''
          echo "adding mediatracker-api for frontend"
          cp -r ../rest-api $out/lib/node_modules/mediatracker-api
      '';
          nativeBuildInputs = [
              pkgs.breakpointHook
          ];
      NODE_OPTIONS = "--openssl-legacy-provider";
  };
    dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cat > $out/bin/mediatracker <<EOF
    #!/bin/sh
    export PUBLIC_PATH=''${PUBLIC_PATH:-$frontend/lib/mediatracker-client}
    exec $backend/bin/mediatracker
    EOF
    chmod +x $out/bin/mediatracker

    runHook postInstall
  '';



  meta = {
    description = "";
    homepage = "https://flood.js.org";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ winter ];
  };
})
