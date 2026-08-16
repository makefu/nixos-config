# Pipe stdin into the krebs pastebin on retiolum. From stockholm's krebs/5pkgs.
{ curl, gnused, writers }:

writers.writeDashBin "kpaste" ''
  ${curl}/bin/curl -sS http://p.r --data-binary @"''${1:--}" \
    -H "Content-Type-Override: ''${KPASTE_CONTENT_TYPE-}" |
  ${gnused}/bin/sed '$ {p;s|http://p.r|https://p.krebsco.de|}'
''
