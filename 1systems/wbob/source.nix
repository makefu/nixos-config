import <stockholm/makefu/source.nix> {
  name="studio";
  override.musnix.git = {
    url = https://github.com/musnix/musnix.git;
    ref = "d8b989f";
  };
}
