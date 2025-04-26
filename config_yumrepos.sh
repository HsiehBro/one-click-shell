#!/usr/bin/env bash
set -euo pipefail

. /etc/os-release
CONFIG_DIR="/etc/yum.repos.d"
ARCH="$(uname -m)"
# string replace //VAR/SRC/TARGET
RELEASEVER="${VERSION_ID//\"/}"

BACKUP_DIR="${CONFIG_DIR}/old"
mkdir -p "${BACKUP_DIR}"
shopt -s nullglob
for repo in "${CONFIG_DIR}"/*.repo; do
  mv -v "${repo}" "${BACKUP_DIR}/"
done
shopt -u nullglob

CDROM_DEV="/dev/sr0"
MOUNT_POINT="/media/cdrom"
if ! grep -qs "^${CDROM_DEV}" /proc/mounts; then
  mkdir -p "${MOUNT_POINT}"
  if ! mount /dev/sr0 /media/cdrom >/dev/null 2>&1; then
    echo "Error: failed to mount ${CDROM_DEV}" >&2
    exit 1
  fi
else
  echo "${CDROM_DEV} already mounted"
fi

cat > "${CONFIG_DIR}/cdrom.repo" << EOF
[cdrom]
name='local cdrom repo'
baseurl="file:///media/cdrom"
gpgcheck=1
gpgkey="file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${releasever}"
EOF

cat > "${CONFIG_DIR}/base.repo" << EOF
[base]
name='aliyun base repo'
baseurl="https://mirrors.aliyun.com/centos/${releasever}/os/${arch}/"
gpgcheck=1
gpgkey="https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-${releasever}"
EOF

cat > "${CONFIG_DIR}/epel.repo" << EOF
[epel]
name='aliyun epel repo'
baseurl="https://mirrors.aliyun.com/epel/${releasever}/${arch}/"
gpgcheck=1
gpgkey="https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-${releasever}"
EOF

yum repolist
