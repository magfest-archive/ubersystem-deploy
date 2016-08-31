#!/bin/bash

# fail on any errors
set -e

if [ -z "$1" ]; then
  echo "usage: $0 [event_name]"
  echo "event_name will be used for naming branches. no spaces or special chars allowed. example: 'super2016'"
  exit -1
fi

event_name="$1"
branch_name="__release__$event_name"

for i in `find -name '.git'`; do
  pushd `dirname $i`
  git fetch
  git checkout -b $branch_name
  git push origin $branch_name
  git status
  popd
done
