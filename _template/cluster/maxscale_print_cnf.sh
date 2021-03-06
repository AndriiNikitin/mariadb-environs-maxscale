#!/bin/bash

set -e

function enum_nodes() {
  local first=1
  for eid in $(cat __clusterdir/nodes.lst) ; do
    [ "$first" == 1 ] || echo -n ', '
    echo -n "$eid"
    first=0
  done
}

function enum_nodes_detailed() {
  for eid in $(cat __clusterdir/nodes.lst) ; do
    cat << EON
[$eid]
type=server
address=127.0.0.1
port=$(__clusterdir/../$eid*/print_port.sh)
protocol=MySQLBackend

EON

  done
}


function write_router_options() {
  if [ -z "$1" ] ; then 
    echo master
  else
    echo $1
  fi
}


function read_router_options() {
  if [ -z "$1" ] ; then 
    echo slave
  else
    echo $1
  fi
}

cat << EOF
[Write-Service]
type=service
router=readconnroute
router_options=$(write_router_options $1)
user=maxscale
passwd=maxscale
servers=$(enum_nodes)

[Read-Service]
type=service
router=readconnroute
router_options=$(read_router_options $1)
user=maxscale
passwd=maxscale
servers=$(enum_nodes)

$(enum_nodes_detailed)

[Replication-Monitor]
type=monitor
module=mysqlmon
servers=$(enum_nodes)
user=maxscale
passwd=maxscale
monitor_interval=10000
EOF
