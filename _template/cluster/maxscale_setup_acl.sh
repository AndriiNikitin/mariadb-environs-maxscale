#!/bin/bash

set -e

# currently works only on localhost

for eid in $(cat __clusterdir/nodes.lst) ; do
  __clusterdir/../$eid*/sql.sh create user if not exists "maxscale"@"127.0.0.1" identified by '"maxscale"'
  __clusterdir/../$eid*/sql.sh grant all on \*.\* to maxscale@127.0.0.1
  __clusterdir/../$eid*/sql.sh create user if not exists "maxscale"@"localhost" identified by '"maxscale"'
  __clusterdir/../$eid*/sql.sh grant all on \*.\* to maxscale@localhost
done
