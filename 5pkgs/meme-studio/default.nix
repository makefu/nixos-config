{
  pkgs,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  google-fonts,
  memeDir ? "", # set a custom meme directory. folder contains memes in webp format plus /memes-with-text-boxes-en.json which defines the layout
}:

buildNpmPackage (finalAttrs: {
  pname = "meme-studio";
  version = "1.0.0-unstable-2025-11-27";

  src = fetchFromGitHub {
    owner = "viclafouch";
    repo = "meme-studio";
    rev = "0c7876086309c5bff28d243372aab02ca9896eaa";
    hash = "sha256-OwnPjw5e3OnHBqqlf7+mNc0h2Mmg+wmVXQjoc7/TVmc=";
  };
  patches = [
      # instead of dynamically loading fonts from google the fonts are copied from the google-fonts package
      ./local-fonts.patch
      ./nextjs-standalone.patch
  ];
  npmDepsHash = "sha256-3RSQNm63yRufZFn4cBbj1C17JKbp2WnzPTwOxYFN3Bo=";
  npmFlags = [ "--legacy-peer-deps" ];
      nativeBuildInputs = [
        # add the breakpoint hook
        pkgs.breakpointHook
        pkgs.vim
    ];
  preBuild = ''
    ${ if memeDir != "" then "cp ${memeDir}/memes-with-text-boxes-en.json src/shared/api/memes-with-text-boxes-en.json" else "" }
    cp "${
      google-fonts.override { fonts = [ "Alata" ]; }
    }/share/fonts/truetype/Alata-Regular.ttf" src/app/alata.ttf
  '';


  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    cp -r .next/standalone $out/share/meme-studio/
    cp -r public $out/share/meme-studio/public
    chmod +x $out/share/meme-studio/server.js

    mkdir -p $out/share/meme-studio/.next
    cp -r .next/static $out/share/meme-studio/.next/static

    makeWrapper "${lib.getExe nodejs}" $out/bin/meme-studio \
      --set-default PORT 3000 \
      --set-default NIXPKGS_MEMESTUDIO_CACHE_DIR /var/cache/meme-studio \
      --add-flags "$out/share/meme-studio/server.js"
    ln -s /var/cache/meme-studio $out/share/meme-studio/.next/cache

    ${ if memeDir == "" then "ln -sf ${memeDir} $out/share/meme-studio/public/templates" else "" }

    runHook postInstall
  '';

  doDist = false;

  meta = {
    description = "A complete and fast website building in Next.js for creating and sharing \"internet memes\"";
    homepage = "https://meme-studio.io";
    #license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ makefu ];
  };
})

