#! /bin/sh
set -eu
printf "Sie meinten wohl \""
echo -n $@ | sed 's/Shack/shack/g'
echo "\""
echo "${_from}--"
