{ pkgs, ... }:
let qemu-arm-static = pkgs.stdenv.mkDerivation {
  name = "qemu-arm-static";
  src = builtins.fetchurl {
    url = "https://github.com/multiarch/qemu-user-static/releases/download/v6.1.0-8/qemu-arm-static";
    sha256 = "06344d77d4f08b3e1b26ff440cb115179c63ca8047afb978602d7922a51231e3";
  };
  dontUnpack = true;
  installPhase = "install -D -m 0755 $src $out/bin/qemu-arm-static";
};
in {
  # Enable binfmt emulation of extra binary formats (armv7l-linux, for exmaple).
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.registrations.arm = {
    interpreter = "${qemu-arm-static}/bin/qemu-arm-static";
    magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
  };

  # Define additional settings for nix.
  nix.extraOptions = ''
    extra-platforms = armv7l-linux
  '';
  nix.sandboxPaths = [ "/run/binfmt/arm=${qemu-arm-static}/bin/qemu-arm-static" ];
}
