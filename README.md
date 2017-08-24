# mariadb-environs-maxscale
Use local environs cluster to generate maxscale config files

Read more about usage in mariadb-environs repo

## Synopsis using Maxscale with local cluster "c1"
```
# make sure cluster is created with maxscale plugin installed:
# ./get_plugin.sh maxscale

# generate templates for using tar maxscale 2.1.6
./replant.sh s1-2.1.6
# download and unpack tar
./build_or_download.sh s1

# add cluster nodes into maxscale config
c1/maxscale_print_cnf.sh >> s1-2.1.6/s.cnf

# setup acl for maxscale in the cluster
c1/maxscale_setup_acl.sh

s1*/startup.sh
# create table in maxscale
s1*/mysql.sh create table t1 select 5
# confirm it is on each node in cluster
c1/mysql.sh 'select * from t1'
```

## Synopsis preparing framework
```
# optional - check environs prerequisites
# sudo yum install git m4 || sudo apt-get install git m4

set -e
# set up framework
if [ ! -e common.sh ] ; then
  [ -d mariadb-environs ] || git clone http://github.com/AndriiNikitin/mariadb-environs
  cd mariadb-environs
  ./get_plugin.sh maxscale
fi

# optional - make sure that prerequisites for MariaDB Server tar are in place
# sudo _template/install_m-version_dep.sh
```

## Synopsis creating simple replication cluster
```
# setup simple replication cluster "c1"
_template/plant_cluster.sh c1
# define two nodes with alias m1 and m2
echo m1 > c1/nodes.lst
echo m2 >> c1/nodes.lst

# generate templates for tar
c1/replant.sh 10.2.8
# download tar if not exists in _depot/m-tar/10.2.8
./build_or_download.sh m1
# setup config files and data dir
c1/gen_cnf.sh
c1/install_db.sh

# now regerate config files with binlog enabled for simpler replication setup
m1*/gen_cnf.sh log-bin

c1/startup.sh

# setup replication
m2*/replicate.sh m1
```

