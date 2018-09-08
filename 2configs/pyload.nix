{pkgs, ... }:
{
  nixpkgs.config.unfreeRedistributable = true;
  users.users.makefu.packages = with pkgs;[
      pyload
      spidermonkey
      tesseract
  ];

}
