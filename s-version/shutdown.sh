#!/bin/bash
set -e
# only this line should present when MXS-1377 is fixed
# kill $(cat __workdir/maxscale.pid) && sleep 1

kill $(cat __workdir/maxscale.pid) 2>/dev/null || :
sleep 1
