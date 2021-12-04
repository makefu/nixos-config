{ stdenv, lib, fetchFromGitHub, python3, kernel, kmod }:
let
  py = python3.withPackages (p: [ p.ConfigArgParse p.pyroute2 p.dbus-python ]);
in
stdenv.mkDerivation rec {
  name = "xmm7360-pci-${version}-${kernel.version}";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "xmm7360";
    repo = "xmm7360-pci";
    rev = "b28714b6fb73887ecd5c0c25ffc0613d6eab6533";
    sha256 = "1f1r3cnnjaxdxig56a9v4wfjq1r2z1wg8lq59klxxnybydk91m60";
  };

  #sourceRoot = "source/linux/v4l2loopback";

  buildTargets = "default";
  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;
  buildInputs = [ kmod ];


  makeFlags = [
    "KVERSION=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];
  installFlags = [ "DEPMOD=true" ];
  postInstall = ''
    install -d $out/lib/xmm7360/
    cp -r rpc/ $out/lib/xmm7360/
    cat > open_xdatachannel <<EOF
    cd $out/lib/xmm7360
    exec ${py}/bin/python3 rpc/open_xdatachannel.py "\$@"
    EOF
    install -D open_xdatachannel $out/bin/open_xdatachannel
  '';

  meta = with lib; {
    description = "A kernel module to create V4L2 loopback devices";
    homepage = "https://github.com/aramg/droidcam";
    license = licenses.gpl2;
    maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
  };
}
