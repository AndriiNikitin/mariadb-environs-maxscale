#!/bin/bash
set -e
. common.sh

# example url  https://downloads.mariadb.com/MaxScale/2.0.5/ubuntu/dists/xenial/main/binary-amd64/maxscale-2.0.5.ubuntu.xenial.tar.gz 

ver=__version
major=${ver%\.*}

if [ "$(detect_yum)" == "yum" ] ; then
  FILE=https://downloads.mariadb.com/MaxScale/${ver}/$(detect_distname)/$(detect_distver)/$(detect_x86)/maxscale-${ver}.$(detect_distname).$(detect_distver).tar.gz
elif [ "$(detect_yum)" == "apt" ] ; then
  FILE=https://downloads.mariadb.com/MaxScale/${ver}/$(detect_distname)/dists/$(detect_distcode)/main/binary-$(detect_amd64)/maxscale-${ver}.$(detect_distname).$(detect_discode).tar.gz
fi

mkdir -p __workdir/../_depot/s-tar/__version

( cd __workdir/../_depot/s-tar/__version && \
[[ -f $(basename $FILE) ]] || wget -nc $FILE && tar -zxf $(basename $FILE) --strip 1 )
