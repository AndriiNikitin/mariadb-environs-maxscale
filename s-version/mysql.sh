#!/bin/bash
# if client is not installed - try to find unpacked tar in depot
mysql="$(which mysql 2>/dev/null)" || mysql="$(ls __workdir/../_depot/m-tar/*/bin/mysql 2>/dev/null | tail -n 1)"

[ ! -z $mysql ] || which mysql

if [ -z $1 ] ; then
  $mysql -S __workdir/write.sock -umaxscale -pmaxscale test
else
  $mysql -S __workdir/write.sock -umaxscale -pmaxscale -e "$*" test
fi

