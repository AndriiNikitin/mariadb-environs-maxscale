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
[Galera Service]
type=service
router=readconnroute
router_options=synced
servers=$(enum_nodes)
user=maxscale
passwd=maxscale


[Galera Listener]
type=listener
service=Galera Service
protocol=MySQLClient
port=__port
socket=__workdir/write.sock

$(enum_nodes_detailed)

[Galera Monitor]
type=monitor
module=galeramon
servers=$(enum_nodes)
user=maxscale
passwd=maxscale

EOF
