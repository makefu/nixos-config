#!/bin/sh
set -eu
URLS=${1?must provide URLS file}
OUTFILE=${2:-all.xml}

echo "init, writing to $OUTFILE"

cat > "$OUTFILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <title>makefu Ebay Kleinanzeigen</title>
    <link>https://www.ebay-kleinanzeigen.de/</link>
    <description>Feed for all kleinanzeigen</description>
    <pubDate>$(date '+%a, %d %b %Y %H:%M:%S %z')</pubDate>
EOF
echo "looping through $URLS"
cat "$URLS" | while read line;do
  echo "fetching $line"
  ratt auto "$line"  | \
  xmlstarlet sel -t -c "//item" >> "$OUTFILE" || :
done

echo "close"
cat >> "$OUTFILE" <<EOF
  </channel>
</rss>
EOF
