{ fetchFromGitLab, buildLinux, ... } @ args:
buildLinux (args // rec {
  version = "4.4.55";
  modDirVersion = "4.4.55";
  extraMeta.branch = "4.4";
  defconfig = "firefly_linux_defconfig";

  src = fetchFromGitLab {
    owner = "TeeFirefly";
    repo = "linux-kernel";
    rev = "firefly_0821_release";
    sha256 = "1fwj9cm5ysz286znrr3fyrhfn903m84i7py4rv3y3h9avxb3zl1r";
  };
  extraMeta.platforms = [ "aarch64-linux" ];
} // (args.argsOverride or {}))
