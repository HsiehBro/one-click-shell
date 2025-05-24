#!/bin/bash

set -u

yum install -y wget gcc pcre-devel openssl-devel

DOWNLOAD_LINK="https://nginx.org/download/nginx-1.28.0.tar.gz"
DOWNLOAD_DIR="/usr/local/src"
NGINX_NAME=$(basename "${DOWNLOAD_LINK}" .tar.gz)
INSTALL_DIR="/opt/${NGINX_NAME}"

if [ ! -e "${DOWNLOAD_DIR}/${NGINX_NAME}.tar.gz" ];then
  wget "${DOWNLOAD_LINK}" -P "${DOWNLOAD_DIR}" && echo "nginx download sucessful..." || { echo "nginx download failed!!!";exit 400; };
fi
if [ ! -e "${DOWNLOAD_DIR}/${NGINX_NAME}" ];then
  tar -xf "${NGINX_NAME}.tar.gz";
fi

./configure --prefix="${INSTALL_DIR}" --with-http_ssl_module
make -j "$(grep -c processor /proc/cpuinfo)" && make install

if [ $? -ne 0 ];then
  rm -rf "/opt/${NGINX_NAME}"
  rm -rf "${DOWNLOAD_DIR}/${NGINX_NAME}"
  exit 400
fi

cat > "/etc/systemd/system/nginx.service" <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=network.target

[Service]
Type=forking
ExecStart="/opt/${NGINX_NAME}"/sbin/nginx
ExecReload="/opt/${NGINX_NAME}"/sbin/nginx -s reload
ExecStop="/opt/${NGINX_NAME}"/sbin/nginx -s quit
PIDFile="/opt/${NGINX_NAME}"/logs/nginx.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nginx.service --now

echo -e "\e[30;31sucess\e[0m install"
