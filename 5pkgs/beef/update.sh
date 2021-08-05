#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl bundix git libiconv libpcap libxml2 libxslt pkg-config postgresql ruby.devEnv sqlite xmlstarlet nix-update wget

set -eu -o pipefail
cd "$(dirname "$(readlink -f "$0")")"


# TODO find the correct tag
echo Fetching latest Gemfile
wget https://raw.githubusercontent.com/beefproject/beef/master/Gemfile -O Gemfile
rm -f Gemfile.lock
echo Running bundler install
bundler install
echo Running bundix
bundix
exit 0

latest=$(curl https://github.com/rapid7/metasploit-framework/releases.atom | xmlstarlet sel -N atom="http://www.w3.org/2005/Atom" -t -m /atom:feed/atom:entry -v atom:title -n | head -n1)
echo "Updating metasploit to $latest"

sed -i "s#refs/tags/.*#refs/tags/$latest\"#" Gemfile

bundler install
bundix
sed -i '/[ ]*dependencies =/d' gemset.nix

cd "../../../../"
nix-update beef --version "$latest"
