#!/bin/bash

# add a primary partition, size is 30G
fdisk /dev/sda <<EOF > /dev/null
n
p

+30G
w
EOF
