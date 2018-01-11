#!/bin/bash

host_file=../../active-hosts.txt

echo "Running updates on hosts specified in $host_file...."

set -e

cat $host_file | fab read_hosts do_security_updates -u root

echo "Done running updates!"
