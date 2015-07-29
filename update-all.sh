#!/bin/bash
set -e

git fetch
git pull

pushd puppet/modules/uber
git fetch
git pull
popd

pushd puppet/hiera/nodes
git fetch
git pull
popd
