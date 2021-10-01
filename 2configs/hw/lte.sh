#/bin/sh

if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root, elevating!"
  exec sudo $0 $1
  exit 0
fi

if [[ "$1" = "down" ]]; then
  echo "taking wwan0 down!"
  ip link set wwan0 down
  rmmod xmm7360
  exit
fi

if [[ "$1" = "up" ]]; then
  echo "running modprobe"
  modprobe xmm7360
  echo "bringing wwan0 up!"
  until open_xdatachannel -a web.vodafone.de;do
    modprobe -r xmm7360
    modprobe  xmm7360
  done
  ip link set wwan0 up
  echo "nameserver 1.1.1.1" | tee -a /etc/resolv.conf
fi
