# optional - check environs prerequisites
# sudo yum install git m4 || sudo apt-get install git m4

set -e

# set up framework
if [ ! -e common.sh ] ; then
  [ -d mariadb-environs ] || git clone http://github.com/AndriiNikitin/mariadb-environs
  cd mariadb-environs
  ./get_plugin.sh maxscale
fi

# optional - make sure that prerequisites for MariaDB tar are in place
# sudo _template/install_m-version_dep.sh

# setup simple replication cluster "c1"
_template/plant_cluster.sh c1
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

# generate templates for maxscale
./replant.sh s1-2.1.6
./build_or_download.sh s1

# generate maxscale config from c1
s1*/gen_replication_cnf.sh c1

# setup acl for maxscale in the cluster
c1/maxscale_setup_acl.sh

s1*/startup.sh
# create table in maxscale
s1*/mysql.sh create table t1 select 5
sleep 1
# confirm it is on each node in cluster
c1/mysql.sh 'select * from t1'


