{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  libx11,
  libxkbcommon,
  wayland,
  libglvnd,
  mesa,
  udev,
}:

rustPlatform.buildRustPackage {
  pname = "m-flasher";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "jvitkauskas";
    repo = "m-flasher";
    rev = "a3a4788d19b88e19e134a14694b91ad1bde4d747";
    hash = "sha256-4EInb2k44HC2JJulH5XHz6PU+MW7GOw0rNVfpnQqsBA=";
  };

  cargoHash = "sha256-yj5Dsre7i//s04eiA/Zqp8SVyF4RqUCM5UTcUqhqlp4=";

  # The tests run against a simulated unit (FakeFlash, /dev/fake); the ones
  # needing real M-VAVE images skip themselves unless FLASHER_TEST_DATA is
  # set, so they pass offline and device-less.
  doCheck = true;

  # Nothing is linked against directly: winit, glutin, glow and rfd dlopen
  # the wayland/x11/GL libraries, so they only need to be reachable at
  # runtime through the wrapper below (see postInstall).
  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  # eframe/glow dlopen libEGL/libGLESv2, so the glvnd dispatcher must come
  # first: pointing LD_LIBRARY_PATH straight at mesa's lib dir instead puts
  # libEGL_mesa.so on the path without its libEGL.so.1 front-end, and glutin
  # then finds no config and the window never opens. The vendor libraries
  # (nvidia/mesa) are picked up from /run/opengl-driver by glvnd itself.
  # The udev rules for the download-mode disk, the desktop entry, the icon
  # and the man page ship in the source tree.
  postInstall = ''
    wrapProgram $out/bin/m-flasher \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libglvnd
          mesa
          wayland
          libxkbcommon
          libx11
          udev
        ]
      }"
    install -Dm644 linux/package/io.github.jvitkauskas.m-flasher.desktop \
      $out/share/applications/io.github.jvitkauskas.m-flasher.desktop
    install -Dm644 linux/m-flasher.png \
      $out/share/icons/hicolor/256x256/apps/io.github.jvitkauskas.m-flasher.png
    install -Dm644 linux/package/m-flasher.1 \
      $out/share/man/man1/m-flasher.1
    install -Dm644 linux/70-m-flasher.rules \
      $out/lib/udev/rules.d/70-m-flasher.rules
  '';

  meta = {
    description = "Back up, restore and install firmware/bootloaders on the M-VAVE FM-1 and SMK-37 over USB";
    homepage = "https://github.com/jvitkauskas/m-flasher";
    license = lib.licenses.mit;
    mainProgram = "m-flasher";
    platforms = lib.platforms.linux;
  };
}
