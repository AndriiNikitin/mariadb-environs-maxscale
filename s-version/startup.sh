mkdir -p __workdir/log
mkdir -p __workdir/datadir

__workdir/../_depot/s-tar/__version/bin/maxscale -f __workdir/s.cnf -L __workdir/log -D __workdir/datadir --piddir=__workdir --syslog=no --libdir=__workdir/../_depot/s-tar/2.1.6/lib/maxscale

