import <stockholm/makefu/source.nix> {
  name="studio";
  override.musnix.git = {
    url = https://github.com/musnix/musnix.git;
    ref = "f0ec1f3";
  };
}
