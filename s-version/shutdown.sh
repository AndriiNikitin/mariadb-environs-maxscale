#!/bin/bash
set -e
kill $(cat __workdir/maxscale.pid) && sleep 1
