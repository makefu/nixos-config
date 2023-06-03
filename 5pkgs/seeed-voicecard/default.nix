{ pkgs, lib, fetchFromGitHub, fetchpatch, kernel, ... }:

pkgs.stdenv.mkDerivation rec {
  name = "seeed-voicecard-${version}-module-${kernel.modDirVersion}";
  version = "v4.1-post";

  src = fetchFromGitHub {
    owner = "respeaker";
    repo = "seeed-voicecard";
    rev = "c52606626de050bdad85803d7e427a64cb0cf05c";
    hash = "sha256-sFReX9Nz9TDRvheKfPijRw1wQ++jJUk5+lOwVmfx3wA=";
  };

  #preConfigure = ''
  #  substituteInPlace Makefile --replace "snd-soc-wm8960-objs := wm8960.o" ""
  #  substituteInPlace Makefile --replace "obj-m += snd-soc-wm8960.o" ""
  #'';

  KERNELDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

  NIX_CFLAGS = ["-Wno-error=cpp"];

  patches = [
    (fetchpatch { url = "https://patch-diff.githubusercontent.com/raw/respeaker/seeed-voicecard/pull/323.patch"; hash = "sha256-coa0ZXDAGYxxi4ShL1HpOebfwOSmIpfdbEIYZtBWlYI="; })
  ];

  nativeBuildInputs = [ pkgs.perl ] ++ kernel.moduleBuildDependencies;
  buildInputs = [ pkgs.alsa-lib ];

  buildPhase = ''
  make -C $KERNELDIR M=$(pwd) modules
  make -C ac108_plugin libasound_module_pcm_ac108.so
  sed -i "s/brcm,bcm2708/raspberrypi/" *.dts
  '';
  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/sound/soc/codecs
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/sound/soc/bcm
    cp snd-soc-wm8960.ko $out/lib/modules/${kernel.modDirVersion}/sound/soc/codecs
    cp snd-soc-ac108.ko $out/lib/modules/${kernel.modDirVersion}/sound/soc/codecs
    cp snd-soc-seeed-voicecard.ko $out/lib/modules/${kernel.modDirVersion}/sound/soc/bcm
    mkdir $out/lib/dts $out/lib/alsa-lib
    cp *.dts $out/lib/dts
    cp ac108_plugin/libasound_module_pcm_ac108.so $out/lib/alsa-lib

  '';
}
