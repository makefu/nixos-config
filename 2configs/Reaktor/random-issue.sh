#! /bin/sh
set -eu
# requires env:
#   $state_dir
#   $origin

# in PATH: git,lentil,coreutils
subdir=`echo "$1" | tr -dc "[:alnum:]"`
name=`echo "$origin" | tr -dc "[:alnum:]"`
track="$state_dir/$name-checkout"
(if test -e "$track" ;then
  cd "$track"
  git fetch origin master
  git reset --hard origin/master
else
  git clone "$origin" "$track"
fi) >&2

cd "$track"
lentil "${subdir:-.}" -f csv | sed 1d | shuf | head -1
