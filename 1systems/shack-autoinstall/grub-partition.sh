#!/bin/sh
set -euf
parted -s ${disk} mklabel msdos
parted -s ${disk} -- mkpart primary linux-swap 1M 4096M
parted -s ${disk} -- mkpart primary ext2 4096M 100%
