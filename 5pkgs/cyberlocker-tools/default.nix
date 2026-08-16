# cput/cdel: put and delete files on the krebs cyberlocker on retiolum.
# From stockholm's krebs/5pkgs.
{ curl, symlinkJoin, writers }:

symlinkJoin {
  name = "cyberlocker-tools";
  paths = [
    (writers.writeDashBin "cput" ''
      set -efu
      path=''${1:-$(hostname)}
      path=$(echo "/$path" | sed -E 's:/+:/:')
      url=http://c.r$path

      ${curl}/bin/curl -fSs --data-binary @- "$url"
      echo "$url"
    '')
    (writers.writeDashBin "cdel" ''
      set -efu
      path=$1
      path=$(echo "/$path" | sed -E 's:/+:/:')
      url=http://c.r$path

      ${curl}/bin/curl -f -X DELETE "$url"
    '')
  ];
}
