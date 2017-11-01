#!/bin/bash

set -e

# currently works only on localhost



for eid in $(cat __clusterdir/nodes.lst) ; do
  was_started=no
  __clusterdir/../$eid*/status.sh &> /dev/null || { __clusterdir/../$eid*/startup.sh && was_started=yes; }
  
  { __clusterdir/../$eid*/sql.sh create user /*M!100100 if not exists*/ "maxscale"@"127.0.0.1" identified by '"maxscale"' && \
     __clusterdir/../$eid*/sql.sh grant all on \*.\* to maxscale@127.0.0.1; } || :

  {  __clusterdir/../$eid*/sql.sh create user /*M!100100 if not exists*/ "maxscale"@"localhost" identified by '"maxscale"' && \
      __clusterdir/../$eid*/sql.sh grant all on \*.\* to maxscale@localhost; } || :

  [ "$was_started" == no ] || __clusterdir/../$eid*/shutdown.sh
done
