#!/bin/sh
set -euf
p(){
  parted -s ${disk} -- $@
}
p mklabel gpt
p mkpart primary fat32 1M 551M
p set 1 boot on
p mkpart primary linux-swap 51M 4647M
p mkpart primary ext2 4647M 100%
udevadm settle
mkfs.fat -nboot -F32 /dev/sda1

udevadm settle
mkswap ${disk}2 -L swap
swapon -L swap
mkfs.ext4 -L nixos ${disk}3
mount LABEL=nixos /mnt
mkdir /mnt/boot
mount LABEL=boot /mnt/boot

mkdir -p /mnt/etc/nixos
cp ${./shack-config.nix} /mnt/etc/nixos/configuration.nix
nixos-generate-config --root /mnt
