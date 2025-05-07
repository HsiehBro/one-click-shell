#!/bin/env bash
set -eu

SCRIPTS_DIR="/etc/sysconfig/network-scripts"
IFNAME="eth0"
SCRIPT_NAME="ifcfg-${IFNAME}"

shopt -s nullglob
for script in $(ls "${SCRIPTS_DIR}"/ifcfg-*); do
  if [ $(basename "${script}" | cut -d- -f2) = lo ];then
    continue
  fi
  echo "rename ${script} --->  ${script}.bak"
  mv "${script}" "${script}".bak
done
shopt -u nullglob

DEVICE="${IFNAME}"
ID=con-"${IFNAME}"
IPADDR=10.0.0.1
PREFIX=24
GATEWAY=10.0.0.254
DNS1=10.0.0.254
# BOOTPROTO=dhcp
DOMAIN=hsieh.com
# NETMASK=255.255.255.0

cat > "${SCRIPTS_DIR}/${SCRIPT_NAME}" << EOF
DEVICE="${DEVICE}"
NAME="${ID}"
IPADDR="${IPADDR}"
PREFIX="${PREFIX}"
GATEWAY="${GATEWAY}"
DNS1="${DNS1}"
EOF

nmcli connection reload
nmcli connection up "${ID}"
nmcli connection
