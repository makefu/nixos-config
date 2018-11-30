#!/bin/sh
dir=$(dirname $0)
oldref=$(cat $dir/nixpkgs.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
nix-shell -p nix-prefetch-git --run 'nix-prefetch-git \
  --url https://github.com/makefu/nixpkgs \
  --rev refs/heads/master' \
> $dir/nixpkgs.json
newref=$(cat $dir/nixpkgs.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
echo "git commit $dir/nixpkgs.json -m 'ma nixpkgs: $oldref -> $newref'"
