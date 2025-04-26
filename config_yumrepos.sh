#!/bin/bash

set -u

. /etc/os-release
CONFIG_DIR=/etc/yum.repos.d
arch="$(arch)"
releasever="${VERSION_ID}"

if [ ! -e "${CONFIG_DIR}/old" ]; then
  mkdir -p "${CONFIG_DIR}/old"
fi
mv "${CONFIG_DIR}/*.repo" "${CONFIG_DIR}/old/" 2>/dev/null

if ! grep -q "^/dev/sr0" /proc/mounts; then
  mount /dev/sr0 /media/cdrom 1>/dev/null 2>1
fi
cd "${CONFIG_DIR}"
cat <<EOF > cdrom.repo
[cdrom]
name='local cdrom repo'
baseurl="file:///media/cdrom"
gpgcheck=1
gpgcheck="file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${releasever}"
EOF

cat <<EOF > base.repo
[base]
name='aliyun base repo'
baseurl="https://mirrors.aliyun.com/centos/${releasever}/os/${arch}/"
gpgcheck=1
gpgkey="https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-${releasever}"
EOF

cat <<EOF > epel.repo
[epel]
name='aliyun epel repo'
baseurl="https://mirrors.aliyun.com/epel/${releasever}/${arch}/"
gpgcheck=1
gpgkey="https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-${releasever}"
EOF

yum repolist
