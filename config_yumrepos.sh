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
name=Local CD-ROM Repository
baseurl="file:///media/cdrom"
gpgcheck=1
gpgkey="file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${RELEASEVER}"
EOF

cat > "${CONFIG_DIR}/base.repo" << EOF
[base]
name=Aliyun Base Repository
baseurl="https://mirrors.aliyun.com/centos/${RELEASEVER}/os/${ARCH}/"
gpgcheck=1
gpgkey="https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-${RELEASEVER}"
EOF

cat > "${CONFIG_DIR}/epel.repo" << EOF
[epel]
name=Aliyun EPEL Repository
baseurl="https://mirrors.aliyun.com/epel/${RELEASEVER}/${ARCH}/"
gpgcheck=1
gpgkey="https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-${RELEASEVER}"
EOF

yum makecache >/dev/null
yum repolist
