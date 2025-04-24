#!/bin/bash

set -u

DOWNLOAD_LINK=https://nginx.org/download/nginx-1.28.0.tar.gz
DOWNLOAD_DIR=/usr/local/src/
NGINX_NAME=`basename ${DOWNLOAD_LINK} .tar.gz`

cd ${DOWNLOAD_DIR}
if [ ! -e ${NGINX_NAME}.tar.gz ];then
  wget ${DOWNLOAD_LINK} -P ${DOWNLOAD_DIR} && echo "nginx download sucessful..." || { echo "nginx download failed!!!";exit 400; };
elif [ ! -e ${NGINX_NAME} ];then
  tar -xf ${NGINX_NAME}.tar.gz;
fi

cd ${NGINX_NAME}
yum install -y gcc pcre-devel openssl-devel
./configure --prefix=/opt/${NGINX_NAME} --with-http_ssl_module
make -j `cat /proc/cpuinfo | grep -c processor` && make install

if [ $? != 0 ];then
  rm -rf /opt/${NGINX_NAME}
  rm -rf ${DOWNLOAD_DIR}${NGINX_NAME}
else
  echo "nginx was built and installed successfully ~"
fi
  
