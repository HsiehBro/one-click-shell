#!/bin/env bash
set -eu

BONDING_NAME=bond0

sudo cat > "/etc/netplan/${BONDING_NAME}.yaml" << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eth1: {}
    eth2: {}
  bonds:
    "${BONDING_NAME}":
      dhcp4: no
      addresses: [10.0.0.100/24]
      interfaces:
        - eth1
        - eth2
      parameters:
        mode: active-backup
        primary: eth2
        mii-monitor-interval: 100
      nameservers:
        addresses: [223.5.5.5]
EOF

sudo netplan apply
cat "/proc/net/bonding/${BONDING_NAME}"
