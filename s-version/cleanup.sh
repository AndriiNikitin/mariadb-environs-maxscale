#!/bin/bash
[ ! -e  __workdir/maxscale.pid ] || { __workdir/shutdown.sh && sleep 2; }
