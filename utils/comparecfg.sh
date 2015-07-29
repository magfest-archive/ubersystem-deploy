#!/bin/bash

set -e

echo "getting config for $1"
./getcfg.sh $1

echo "getting config for $2"
./getcfg.sh $2

diff $1.cfg $2.cfg > cfg.diff

echo "open cfg.diff and inspect the contents to see the difference between $1 and $2"
