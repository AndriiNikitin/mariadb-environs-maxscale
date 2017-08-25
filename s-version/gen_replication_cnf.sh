#!/bin/bash

set -e

[ ! -z "$1" ] || { >&2 echo "expected node list as parameter (cluster dir or nodes.lst file or node list)"; exit 1; }

[ ! -f "$1" ] || node_list=$(cat "$1")
[ ! -d "$1" ] || [ ! -f "$1"/nodes.lst ] ||  node_list=$(cat "$1"/nodes.lst)

[ ! -z "$node_list" ] || node_list="$1"

function enum_nodes() {
  local first=1
  for eid in $node_list ; do
    [ "$first" == 1 ] || echo -n ', '
    echo -n "$eid"
    first=0
  done
}

function enum_nodes_detailed() {
  for eid in $node_list ; do
    cat << EON
[$eid]
type=server
address=127.0.0.1
port=$(__workdir/../$eid*/print_port.sh)
protocol=MySQLBackend

EON

  done
}

cat << EOF > __workdir/s.cnf
[Write Listener]
type=listener
service=Write-Service
protocol=MySQLClient
port=__port
socket=__workdir/write.sock

[Read Listener]
type=listener
service=Read-Service
protocol=MySQLClient
port=__port1
socket=__workdir/read.sock

[Write-Service]
type=service
router=readconnroute
router_options=master
user=maxscale
passwd=maxscale
servers=$(enum_nodes)

[Read-Service]
type=service
router=readconnroute
router_options=slave
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
