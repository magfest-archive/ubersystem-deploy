#!/bin/bash

if [ -z "$1" ]
then
        echo "Usage: $0 hostname-to-affect"
        exit -1
fi

hostn=$1

fab -u root -H $hostn puppet_apply
