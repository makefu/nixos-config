{pkgs, ... }:
{
  users.users.makefu.packages = with pkgs;[
      pyload
      spidermonkey
      tesseract
  ];

}
