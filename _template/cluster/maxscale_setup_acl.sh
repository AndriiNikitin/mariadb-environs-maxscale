#!/bin/bash

set -e

# currently works only on localhost

for eid in $(cat __clusterdir/nodes.lst) ; do
  $eid*/sql.sh create user if not exists "maxscale"@"127.0.0.1" identified by '"maxscale"'
  $eid*/sql.sh grant all on \*.\* to maxscale@127.0.0.1
done
